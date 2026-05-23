import SwiftUI
import SwiftData

struct AhaDetailView: View {
    let ahaMoment: AhaMoment
    @Environment(\.modelContext) var modelContext
    @Environment(AppViewModel.self) var appVM
    @Environment(\.dismiss) var dismiss

    @State private var dialogueVM = DialogueViewModel()
    @State private var confirmationVM = ConfirmationViewModel()
    @State private var reportVM = ReportViewModel()

    @State private var inputText = ""
    @State private var showReport = false
    @State private var isTranscribing = false
    @State private var asrError: String?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                headerSection

                switch ahaMoment.phase {
                case .captured:
                    capturedPhaseView
                case .dialoguing:
                    dialoguePhaseView
                case .confirming:
                    confirmationPhaseView
                case .completed:
                    completedPhaseView
                }
            }
            .padding()
        }
        .navigationTitle(ahaMoment.title)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showReport) {
            if let report = ahaMoment.report {
                ReportView(report: report)
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                PhaseBadge(phase: ahaMoment.phase)
                Spacer()
                Text(ahaMoment.createdAt, style: .date)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(ahaMoment.keywords, id: \.self) { keyword in
                        KeywordCapsule(text: keyword)
                    }
                }
            }

            if let project = ahaMoment.taggedProjectName {
                Label(project, systemImage: "folder")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if !ahaMoment.resources.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("相关资源")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    ForEach(ahaMoment.resources) { resource in
                        HStack {
                            Image(systemName: resource.type.iconName)
                            Text(resource.title)
                                .font(.caption)
                                .lineLimit(1)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Phase Views

    private var capturedPhaseView: some View {
        VStack(spacing: 16) {
            Text("关键词已捕捉，准备好展开对话了？")
                .foregroundStyle(.secondary)

            Button {
                dialogueVM.setup(ahaMoment: ahaMoment, modelContext: modelContext)
            } label: {
                Label("开始对话", systemImage: "mic.fill")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding(.top)
    }

    private var dialoguePhaseView: some View {
        VStack(spacing: 12) {
            ForEach(dialogueVM.messages) { msg in
                DialogueBubbleView(message: msg)
            }

            if let error = dialogueVM.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .padding(.horizontal)
            }

            if dialogueVM.isLoading {
                HStack {
                    Spacer()
                    ProgressView()
                    Text("AI思考中...")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                }
                .padding()
            }

            if isTranscribing {
                HStack {
                    Spacer()
                    ProgressView()
                    Text("语音识别中...")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                }
                .padding()
            }

            if isPolishing {
                HStack {
                    Spacer()
                    ProgressView()
                    Text("整理语音内容中...")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                }
                .padding()
            }

            if let error = asrError {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .padding(.horizontal)
            }

            VStack(spacing: 8) {
                TextEditor(text: $inputText)
                    .frame(minHeight: 80, maxHeight: 200)
                    .padding(8)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay(
                        Group {
                            if inputText.isEmpty {
                                Text("说出你的想法...")
                                    .foregroundStyle(.secondary)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 16)
                                    .allowsHitTesting(false)
                            }
                        }, alignment: .topLeading
                    )

                HStack {
                    Spacer()

                    // Mic button + recording indicator
                    ZStack {
                        Button {
                            toggleRecording()
                        } label: {
                            Image(systemName: appVM.audioRecorder.isRecording ? "stop.circle.fill" : "mic.circle.fill")
                                .font(.title2)
                                .foregroundStyle(appVM.audioRecorder.isRecording ? .red : Color.accentColor)
                        }
                        .disabled(isTranscribing || isPolishing)

                        if appVM.audioRecorder.isRecording {
                            Text("\(appVM.audioRecorder.elapsedSeconds)s")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 4)
                                .padding(.vertical, 2)
                                .background(appVM.audioRecorder.shouldWarn ? .red : .orange)
                                .clipShape(Capsule())
                                .offset(y: -18)
                        }
                    }

                    // Time limit warning
                    if appVM.audioRecorder.shouldWarn {
                        Text("还剩\(appVM.audioRecorder.remainingSeconds)秒，可以先结束，下一轮继续")
                            .font(.caption)
                            .foregroundStyle(.red)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color.red.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }

                    Button {
                        Task {
                            let text = inputText
                            inputText = ""
                            await dialogueVM.sendUserMessage(
                                text: text,
                                modelContext: modelContext,
                                llmClient: appVM.llmClient
                            )
                        }
                    } label: {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.title2)
                    }
                    .disabled(inputText.isEmpty || dialogueVM.isLoading || isTranscribing || isPolishing)
                }
            }

            if !dialogueVM.messages.isEmpty {
                Button {
                    dialogueVM.finishDialogue()
                    Task {
                        await confirmationVM.setup(
                            ahaMoment: ahaMoment,
                            modelContext: modelContext,
                            llmClient: appVM.llmClient
                        )
                    }
                } label: {
                    Text("对话完成，进入确认")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                .buttonStyle(.bordered)
            }
        }
        .onAppear {
            if !dialogueVM.isReady {
                dialogueVM.setup(ahaMoment: ahaMoment, modelContext: modelContext)
            }
        }
    }

    private var confirmationPhaseView: some View {
        VStack(spacing: 12) {
            ForEach(confirmationVM.messages) { msg in
                VStack(alignment: .leading, spacing: 4) {
                    Text(msg.role == .assistant ? "AI理解" : "你的反馈")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(msg.role == .assistant ? .blue : .green)
                    Text(msg.content)
                        .font(.subheadline)
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(msg.role == .assistant ? Color.blue.opacity(0.1) : Color.green.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }

            if confirmationVM.isLoading {
                ProgressView("AI正在理解...")
                    .padding()
            }

            if confirmationVM.isConfirmed {
                VStack(spacing: 12) {
                    Text("AI理解已确认！")
                        .font(.headline)
                        .foregroundStyle(.green)

                    Button {
                        Task {
                            await reportVM.generateReport(
                                ahaMoment: ahaMoment,
                                confirmationVM: confirmationVM,
                                modelContext: modelContext,
                                llmClient: appVM.llmClient
                            )
                            if reportVM.report != nil {
                                showReport = true
                            }
                        }
                    } label: {
                        Label("生成报告", systemImage: "doc.text.fill")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.accentColor)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                .padding()
            } else if !confirmationVM.isLoading {
                HStack {
                    TextField("纠正或补充...", text: $inputText, axis: .vertical)
                        .lineLimit(1...4)
                        .textFieldStyle(.roundedBorder)

                    Button {
                        Task {
                            let feedback = inputText
                            inputText = ""
                            await confirmationVM.sendFeedback(
                                feedback,
                                modelContext: modelContext,
                                llmClient: appVM.llmClient
                            )
                        }
                    } label: {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.title2)
                    }
                    .disabled(inputText.isEmpty)
                }

                HStack {
                    Button("确认理解正确") {
                        confirmationVM.confirmUnderstanding(modelContext: modelContext)
                    }
                    .buttonStyle(.borderedProminent)

                    Spacer()

                    Button("需要纠正") {}
                        .buttonStyle(.bordered)
                }
            }
        }
    }

    private var completedPhaseView: some View {
        VStack(spacing: 16) {
            if ahaMoment.report != nil {
                Button {
                    showReport = true
                } label: {
                    Label("查看报告", systemImage: "doc.text.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                Button {
                    ahaMoment.transition(to: .dialoguing)
                    dialogueVM.setup(ahaMoment: ahaMoment, modelContext: modelContext)
                } label: {
                    Label("继续对话迭代", systemImage: "arrow.clockwise")
                        .font(.subheadline)
                }
                .buttonStyle(.bordered)
            } else if reportVM.isLoading {
                ProgressView("正在生成报告...")
                    .padding()
            } else if let error = reportVM.errorMessage {
                VStack {
                    Text(error)
                        .foregroundStyle(.red)
                    Button("重试") {
                        Task {
                            await reportVM.generateReport(
                                ahaMoment: ahaMoment,
                                confirmationVM: confirmationVM,
                                modelContext: modelContext,
                                llmClient: appVM.llmClient
                            )
                        }
                    }
                    .buttonStyle(.bordered)
                }
            }
        }
        .padding(.top)
    }

    // MARK: - Recording

    @State private var isPolishing = false

    private func toggleRecording() {
        asrError = nil

        if appVM.audioRecorder.isRecording {
            let audioURL = appVM.audioRecorder.stopRecording()
            guard let url = audioURL else { return }

            isTranscribing = true
            Task {
                do {
                    guard let asrClient = appVM.asrClient else {
                        throw ASRError.missingCredentials
                    }
                    let rawText = try await asrClient.recognize(audioURL: url)
                    if !rawText.isEmpty {
                        // Polish the raw ASR text with LLM
                        isTranscribing = false
                        isPolishing = true
                        let polishedText = await polishVoiceText(rawText)
                        inputText = polishedText ?? rawText
                        isPolishing = false
                    }
                } catch {
                    asrError = error.localizedDescription
                    isTranscribing = false
                }
                try? FileManager.default.removeItem(at: url)
            }
        } else {
            do {
                try appVM.audioRecorder.startRecording()
            } catch {
                asrError = "录音失败：\(error.localizedDescription)"
            }
        }
    }

    private func polishVoiceText(_ rawText: String) async -> String? {
        guard let client = appVM.llmClient else { return nil }
        let prompt = PromptBuilder.voicePolishPrompt(rawText: rawText)
        let messages = [
            ChatMessage(role: .system, content: prompt),
            ChatMessage(role: .user, content: rawText)
        ]
        do {
            return try await client.chat(messages: messages)
        } catch {
            return nil
        }
    }
}
