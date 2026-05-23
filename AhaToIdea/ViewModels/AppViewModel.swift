import Foundation
import SwiftData

@Observable
final class AppViewModel {
    var llmClient: LLMClient?
    var audioRecorder = AudioRecordingService()
    var asrClient: TencentASRClient?
    var ttsService = TTSService()

    var apiKey: String {
        get { UserDefaults.standard.string(forKey: "llm_api_key") ?? "" }
        set { UserDefaults.standard.set(newValue, forKey: "llm_api_key") }
    }

    var llmProvider: String {
        get { UserDefaults.standard.string(forKey: "llm_provider") ?? "openai" }
        set { UserDefaults.standard.set(newValue, forKey: "llm_provider") }
    }

    var tencentSecretId: String {
        get { UserDefaults.standard.string(forKey: "tencent_secret_id") ?? "" }
        set { UserDefaults.standard.set(newValue, forKey: "tencent_secret_id") }
    }

    var tencentSecretKey: String {
        get { UserDefaults.standard.string(forKey: "tencent_secret_key") ?? "" }
        set { UserDefaults.standard.set(newValue, forKey: "tencent_secret_key") }
    }

    func setupLLMClient() {
        let key = apiKey
        guard !key.isEmpty else { return }

        switch llmProvider {
        case "deepseek":
            llmClient = DeepSeekClient(apiKey: key)
        default:
            llmClient = OpenAIClient(apiKey: key)
        }
    }

    func setupASRClient() {
        let id = tencentSecretId
        let key = tencentSecretKey
        guard !id.isEmpty, !key.isEmpty else { return }
        asrClient = TencentASRClient(secretId: id, secretKey: key)
    }

    init() {
        setupLLMClient()
        setupASRClient()
    }
}
