import SwiftUI
import SwiftData

struct CaptureView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss

    @State private var vm = CaptureViewModel()
    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Keywords input
                    VStack(alignment: .leading, spacing: 8) {
                        Text("记下你的想法")
                            .font(.headline)
                        TextEditor(text: $vm.rawText)
                            .focused($isTextFieldFocused)
                            .frame(minHeight: 80)
                            .padding(8)
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.accentColor.opacity(isTextFieldFocused ? 0.5 : 0), lineWidth: 2)
                            )
                            .overlay(alignment: .topLeading) {
                                if vm.rawText.isEmpty {
                                    Text("输入关键词，用空格、逗号或顿号分隔")
                                        .foregroundStyle(.secondary)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 16)
                                        .allowsHitTesting(false)
                                }
                            }

                        // Live keyword capsules
                        if !vm.parsedKeywords.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 6) {
                                    ForEach(vm.parsedKeywords, id: \.self) { keyword in
                                        KeywordCapsule(text: keyword)
                                    }
                                }
                            }
                        }
                    }

                    // Project name
                    VStack(alignment: .leading, spacing: 8) {
                        Text("关联项目（可选）")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        TextField("项目名称", text: $vm.projectName)
                            .textFieldStyle(.roundedBorder)
                    }

                    // Resource picker (collapsed by default)
                    DisclosureGroup("附加资源（可选）") {
                        VStack(spacing: 12) {
                            HStack(spacing: 12) {
                                ResourceButton(icon: "note.text", label: "笔记") {
                                    vm.showResourcePicker = true
                                }
                                ResourceButton(icon: "link", label: "链接") {
                                    vm.showResourcePicker = true
                                }
                                ResourceButton(icon: "photo", label: "照片") {
                                    // TODO: photo picker
                                }
                                ResourceButton(icon: "doc", label: "文件") {
                                    // TODO: document picker
                                }
                            }

                            // Existing resources
                            ForEach(Array(vm.resources.enumerated()), id: \.offset) { index, resource in
                                HStack {
                                    Image(systemName: resource.type.iconName)
                                        .foregroundStyle(.secondary)
                                    Text(resource.title)
                                        .font(.subheadline)
                                        .lineLimit(1)
                                    Spacer()
                                    Button {
                                        vm.removeResource(at: index)
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color(.systemGray6))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                        }
                        .padding(.top, 8)
                    }
                    .font(.subheadline)

                    Spacer(minLength: 100)
                }
                .padding()
            }
            .navigationTitle("随手记")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        let aha = vm.save(modelContext: modelContext)
                        vm.reset()
                        dismiss()
                    }
                    .disabled(vm.rawText.trimmingCharacters(in: .whitespaces).isEmpty)
                    .fontWeight(.semibold)
                }
            }
            .onAppear {
                isTextFieldFocused = true
            }
            .sheet(isPresented: $vm.showResourcePicker) {
                AddResourceSheet(vm: vm)
            }
        }
    }
}

struct ResourceButton: View {
    let icon: String
    let label: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.title3)
                Text(label)
                    .font(.caption2)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .foregroundStyle(.primary)
    }
}

struct AddResourceSheet: View {
    @Bindable var vm: CaptureViewModel
    @Environment(\.dismiss) var dismiss
    @State private var resourceType = ResourceType.textNote
    @State private var title = ""
    @State private var content = ""
    @State private var urlString = ""

    var body: some View {
        NavigationStack {
            Form {
                Picker("类型", selection: $resourceType) {
                    Text("文本笔记").tag(ResourceType.textNote)
                    Text("链接").tag(ResourceType.url)
                }
                .pickerStyle(.segmented)

                TextField("标题", text: $title)

                if resourceType == .textNote {
                    TextField("内容", text: $content, axis: .vertical)
                        .lineLimit(3...6)
                } else {
                    TextField("URL", text: $urlString)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }
            }
            .navigationTitle("添加资源")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("添加") {
                        if resourceType == .textNote {
                            vm.addTextResource(title: title.isEmpty ? "笔记" : title, content: content)
                        } else {
                            vm.addURLResource(title: title.isEmpty ? urlString : title, url: urlString)
                        }
                        dismiss()
                    }
                    .disabled(resourceType == .textNote ? content.isEmpty : urlString.isEmpty)
                }
            }
        }
    }
}
