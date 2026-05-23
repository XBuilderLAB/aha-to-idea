import Foundation

struct ChatMessage: Codable, Identifiable {
    var id: UUID = UUID()
    let role: Role
    let content: String

    enum Role: String, Codable {
        case system
        case user
        case assistant
    }
}

enum LLMError: LocalizedError {
    case httpError(statusCode: Int, message: String)

    var errorDescription: String? {
        switch self {
        case .httpError(let code, let message):
            return "API错误(\(code)): \(message)"
        }
    }
}

protocol LLMClient {
    func chat(messages: [ChatMessage]) async throws -> String
    func stream(messages: [ChatMessage]) -> AsyncThrowingStream<String, Error>
}

final class OpenAIClient: LLMClient {
    private let apiKey: String
    private let model: String
    private let baseURL: String
    private let session = URLSession.shared

    init(apiKey: String, model: String = "gpt-4o-mini", baseURL: String = "https://api.openai.com/v1") {
        self.apiKey = apiKey
        self.model = model
        self.baseURL = baseURL
    }

    func chat(messages: [ChatMessage]) async throws -> String {
        let url = URL(string: "\(baseURL)/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "model": model,
            "messages": messages.map { ["role": $0.role.rawValue, "content": $0.content] },
            "temperature": 0.7
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await session.data(for: request)

        if let httpResponse = response as? HTTPURLResponse,
           !(200...299).contains(httpResponse.statusCode) {
            let responseBody = String(data: data, encoding: .utf8) ?? "Unknown error"
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let error = json["error"] as? [String: Any],
               let message = error["message"] as? String {
                throw LLMError.httpError(statusCode: httpResponse.statusCode, message: message)
            }
            throw LLMError.httpError(statusCode: httpResponse.statusCode, message: String(responseBody.prefix(200)))
        }

        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        let choices = json?["choices"] as? [[String: Any]]
        let message = choices?.first?["message"] as? [String: Any]
        let content = message?["content"] as? String ?? ""
        return content
    }

    func stream(messages: [ChatMessage]) -> AsyncThrowingStream<String, Error> {
        AsyncThrowingStream { continuation in
            Task {
                do {
                    let url = URL(string: "\(baseURL)/chat/completions")!
                    var request = URLRequest(url: url)
                    request.httpMethod = "POST"
                    request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
                    request.setValue("application/json", forHTTPHeaderField: "Content-Type")

                    let body: [String: Any] = [
                        "model": model,
                        "messages": messages.map { ["role": $0.role.rawValue, "content": $0.content] },
                        "temperature": 0.7,
                        "stream": true
                    ]
                    request.httpBody = try JSONSerialization.data(withJSONObject: body)

                    let (bytes, response) = try await session.bytes(for: request)

                    if let httpResponse = response as? HTTPURLResponse,
                       !(200...299).contains(httpResponse.statusCode) {
                        var errorBody = ""
                        for try await line in bytes.lines {
                            errorBody += line
                        }
                        if let data = errorBody.data(using: .utf8),
                           let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                           let error = json["error"] as? [String: Any],
                           let message = error["message"] as? String {
                            throw LLMError.httpError(statusCode: httpResponse.statusCode, message: message)
                        }
                        throw LLMError.httpError(statusCode: httpResponse.statusCode, message: String(errorBody.prefix(200)))
                    }

                    for try await line in bytes.lines {
                        guard line.hasPrefix("data: "), line != "data: [DONE]" else { continue }
                        let jsonString = String(line.dropFirst(6))
                        if let data = jsonString.data(using: .utf8),
                           let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                           let choices = json["choices"] as? [[String: Any]],
                           let delta = choices.first?["delta"] as? [String: Any],
                           let content = delta["content"] as? String {
                            continuation.yield(content)
                        }
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
}

final class DeepSeekClient: LLMClient {
    private let client: OpenAIClient

    init(apiKey: String, model: String = "deepseek-chat") {
        self.client = OpenAIClient(apiKey: apiKey, model: model, baseURL: "https://api.deepseek.com")
    }

    func chat(messages: [ChatMessage]) async throws -> String {
        try await client.chat(messages: messages)
    }

    func stream(messages: [ChatMessage]) -> AsyncThrowingStream<String, Error> {
        client.stream(messages: messages)
    }
}
