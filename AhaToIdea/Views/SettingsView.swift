import SwiftUI

struct SettingsView: View {
    @Environment(AppViewModel.self) var appVM
    @Environment(\.dismiss) var dismiss

    @State private var apiKey = ""
    @State private var provider = "openai"
    @State private var secretId = ""
    @State private var secretKey = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("LLM 配置") {
                    Picker("服务提供商", selection: $provider) {
                        Text("OpenAI").tag("openai")
                        Text("DeepSeek").tag("deepseek")
                    }
                    .pickerStyle(.segmented)

                    SecureField("API Key", text: $apiKey)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()

                    Button("保存 LLM 配置") {
                        appVM.apiKey = apiKey
                        appVM.llmProvider = provider
                        appVM.setupLLMClient()
                    }
                    .disabled(apiKey.isEmpty)
                }

                Section("语音识别（腾讯云 ASR）") {
                    TextField("SecretId", text: $secretId)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()

                    SecureField("SecretKey", text: $secretKey)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()

                    Button("保存 ASR 配置") {
                        appVM.tencentSecretId = secretId
                        appVM.tencentSecretKey = secretKey
                        appVM.setupASRClient()
                    }
                    .disabled(secretId.isEmpty || secretKey.isEmpty)

                    Link("前往腾讯云控制台获取密钥", destination: URL(string: "https://console.cloud.tencent.com/cam/capi")!)
                        .font(.caption)
                }

                Section("语音合成") {
                    Text("使用系统内置 TTS 服务")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Section("关于") {
                    HStack {
                        Text("版本")
                        Spacer()
                        Text("0.1.0")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("设置")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完成") { dismiss() }
                }
            }
            .onAppear {
                apiKey = appVM.apiKey
                provider = appVM.llmProvider
                secretId = appVM.tencentSecretId
                secretKey = appVM.tencentSecretKey
            }
        }
    }
}
