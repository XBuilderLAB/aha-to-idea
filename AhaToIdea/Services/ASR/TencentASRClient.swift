import Foundation
import CryptoKit

enum ASRError: LocalizedError {
    case noRecording
    case recognitionFailed(String)
    case missingCredentials
    case taskNotFound

    var errorDescription: String? {
        switch self {
        case .noRecording: return "没有找到录音文件"
        case .recognitionFailed(let msg): return "识别失败：\(msg)"
        case .missingCredentials: return "请先在设置中配置腾讯云密钥"
        case .taskNotFound: return "识别任务不存在"
        }
    }
}

final class TencentASRClient {
    private let secretId: String
    private let secretKey: String
    private let service = "asr"
    private let host = "asr.tencentcloudapi.com"
    private let region = "ap-guangzhou"

    init(secretId: String, secretKey: String) {
        self.secretId = secretId
        self.secretKey = secretKey
    }

    // MARK: - CreateRecTask (录音文件识别，支持长音频)

    func recognize(audioURL: URL, engineType: String = "16k_zh") async throws -> String {
        let audioData = try Data(contentsOf: audioURL)
        let base64Audio = audioData.base64EncodedString()

        // Step 1: Create recognition task
        let createBody: [String: Any] = [
            "EngineModelType": engineType,
            "SourceType": 1,
            "ChannelNum": 1,
            "ResTextFormat": 0,
            "Data": base64Audio,
            "DataLen": audioData.count,
            "FilterModal": 1
        ]
        let createResponse = try await sendRequest(action: "CreateRecTask", body: createBody)

        guard let taskId = createResponse["Data"] as? [String: Any],
              let id = taskId["TaskId"] as? Int else {
            let error = createResponse["Error"] as? [String: Any]
            let msg = error?["Message"] as? String ?? "创建任务失败"
            throw ASRError.recognitionFailed(msg)
        }

        // Step 2: Poll for result
        return try await pollTaskStatus(taskId: id)
    }

    private func pollTaskStatus(taskId: Int) async throws -> String {
        let maxAttempts = 60
        let interval: UInt64 = 2_000_000_000 // 2 seconds

        for _ in 0..<maxAttempts {
            try await Task.sleep(nanoseconds: interval)

            let queryBody: [String: Any] = ["TaskId": taskId]
            let response = try await sendRequest(action: "DescribeTaskStatus", body: queryBody)

            if let error = response["Error"] as? [String: Any] {
                let msg = error["Message"] as? String ?? "查询任务失败"
                throw ASRError.recognitionFailed(msg)
            }

            guard let data = response["Data"] as? [String: Any],
                  let status = data["StatusStr"] as? String else {
                throw ASRError.recognitionFailed("无法读取任务状态")
            }

            switch status {
            case "success":
                return data["Result"] as? String ?? ""
            case "failed":
                let errMsg = data["ErrorMsg"] as? String ?? "识别失败"
                throw ASRError.recognitionFailed(errMsg)
            default:
                // "waiting" or "doing" — continue polling
                continue
            }
        }

        throw ASRError.recognitionFailed("识别超时，请稍后重试")
    }

    // MARK: - Generic API Request with TC3 Signing

    private func sendRequest(action: String, body: [String: Any]) async throws -> [String: Any] {
        let bodyData = try JSONSerialization.data(withJSONObject: body)
        let bodyString = String(data: bodyData, encoding: .utf8) ?? ""

        let timestamp = Int(Date().timeIntervalSince1970)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        let date = dateFormatter.string(from: Date())

        let contentType = "application/json; charset=utf-8"
        let actionLower = action.lowercased()
        let canonicalHeaders = "content-type:\(contentType)\nhost:\(host)\nx-tc-action:\(actionLower)\n"
        let signedHeaders = "content-type;host;x-tc-action"
        let hashedPayload = Self.sha256Hex(bodyString)

        let canonicalRequest = "POST\n/\n\n\(canonicalHeaders)\n\(signedHeaders)\n\(hashedPayload)"

        let credentialScope = "\(date)/\(service)/tc3_request"
        let stringToSign = "TC3-HMAC-SHA256\n\(timestamp)\n\(credentialScope)\n\(Self.sha256Hex(canonicalRequest))"

        let secretDate = Self.hmacSha256(key: Data("TC3\(secretKey)".utf8), data: Data(date.utf8))
        let secretService = Self.hmacSha256(key: secretDate, data: Data(service.utf8))
        let secretSigning = Self.hmacSha256(key: secretService, data: Data("tc3_request".utf8))
        let signature = Self.hmacSha256Hex(key: secretSigning, data: Data(stringToSign.utf8))

        let authorization = "TC3-HMAC-SHA256 Credential=\(secretId)/\(credentialScope), SignedHeaders=\(signedHeaders), Signature=\(signature)"

        var request = URLRequest(url: URL(string: "https://\(host)")!)
        request.httpMethod = "POST"
        request.setValue(authorization, forHTTPHeaderField: "Authorization")
        request.setValue(contentType, forHTTPHeaderField: "Content-Type")
        request.setValue(host, forHTTPHeaderField: "Host")
        request.setValue(action, forHTTPHeaderField: "X-TC-Action")
        request.setValue("2019-06-14", forHTTPHeaderField: "X-TC-Version")
        request.setValue("\(timestamp)", forHTTPHeaderField: "X-TC-Timestamp")
        request.setValue(region, forHTTPHeaderField: "X-TC-Region")
        request.httpBody = bodyData

        let (data, _) = try await URLSession.shared.data(for: request)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        return json?["Response"] as? [String: Any] ?? [:]
    }

    // MARK: - Crypto Helpers

    private static func sha256Hex(_ string: String) -> String {
        let digest = SHA256.hash(data: Data(string.utf8))
        return digest.map { String(format: "%02x", $0) }.joined()
    }

    private static func hmacSha256(key: Data, data: Data) -> Data {
        let symmetricKey = SymmetricKey(data: key)
        let hmac = HMAC<SHA256>.authenticationCode(for: data, using: symmetricKey)
        return Data(hmac)
    }

    private static func hmacSha256Hex(key: Data, data: Data) -> String {
        let hmacData = hmacSha256(key: key, data: data)
        return hmacData.map { String(format: "%02x", $0) }.joined()
    }
}
