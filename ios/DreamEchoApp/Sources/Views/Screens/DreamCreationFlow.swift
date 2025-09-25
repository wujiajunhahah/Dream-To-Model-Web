import SwiftUI

struct DreamCreationFlow: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var coordinator: NavigationCoordinator
    @StateObject private var viewModel = DreamCreationViewModel()
    @State private var showResetAlert = false

    var body: some View {
        NavigationStack(path: $viewModel.navigationPath) {
            stepView(for: viewModel.currentStep)
                .navigationDestination(for: DreamCreationStep.self) { step in
                    stepView(for: step)
                }
                .navigationTitle(viewModel.currentStep.navigationTitle)
                .navigationBarBackButtonHidden(true)
                .toolbarBackground(.visible, for: .navigationBar)
                .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        leadingButton
                    }
                    ToolbarItem(placement: .primaryAction) {
                        trailingButton
                    }
                }
        }
        .toast(message: viewModel.errorMessage, isPresented: $viewModel.isShowingError)
        .task { viewModel.bindAppState(appState) }
        .onChange(of: viewModel.navigationPath) { _, _ in
            viewModel.syncCurrentStep()
        }
        .alert("清空当前创作？", isPresented: $showResetAlert) {
            Button("保留", role: .cancel) {}
            Button("清空", role: .destructive) {
                viewModel.resetForm()
            }
        } message: {
            Text("表单内容将被重置，但不会影响已生成的梦境。")
        }
    }

    private var leadingButton: some View {
        if viewModel.currentStep == .description {
            Button {
                showResetAlert = true
            } label: {
                Label("清空", systemImage: "arrow.counterclockwise")
            }
            .disabled(!viewModel.canResetForm)
        } else {
            Button {
                viewModel.goBack()
            } label: {
                Label("返回", systemImage: "chevron.left")
            }
        }
    }

    private var trailingButton: some View {
        Group {
            if viewModel.currentStep == .progress, !viewModel.isSubmitting {
                Button("完成") {
                    viewModel.finish()
                    coordinator.switchTo(.library)
                }
            }
        }
    }

    @ViewBuilder
    private func stepView(for step: DreamCreationStep) -> some View {
        switch step {
        case .description:
            DreamDescriptionStep(viewModel: viewModel)
        case .styling:
            DreamStylingStep(viewModel: viewModel)
        case .review:
            DreamReviewStep(viewModel: viewModel)
        case .progress:
            DreamProgressStep(viewModel: viewModel, appState: appState, coordinator: coordinator)
        }
    }
}

enum DreamCreationStep: Int, CaseIterable, Hashable {
    case description
    case styling
    case review
    case progress

    var navigationTitle: String {
        switch self {
        case .description: return "梦境工坊"
        case .styling: return "情绪与风格"
        case .review: return "生成确认"
        case .progress: return "DreamSync"
        }
    }

    var displayTitle: String {
        switch self {
        case .description: return "描述梦境"
        case .styling: return "设定风格"
        case .review: return "确认生成"
        case .progress: return "生成进度"
        }
    }

    var detail: String {
        switch self {
        case .description: return "写下梦境与灵感，我们会提取关键词并生成DreamScript。"
        case .styling: return "选择情绪、艺术风格与区块链，塑造梦境呈现方式。"
        case .review: return "确认最终细节，确保每个参数都与你的梦想契合。"
        case .progress: return "DreamSync 正在构建 3D 模型，可随时返回梦境库查看结果。"
        }
    }
}

@MainActor
final class DreamCreationViewModel: ObservableObject {
    @Published var navigationPath: [DreamCreationStep] = []
    @Published var currentStep: DreamCreationStep = .description

    @Published var title = ""
    @Published var description = ""
    @Published var selectedMood: Mood = .serene
    @Published var selectedStyle: Style = .ethereal
    @Published var selectedBlockchain: BlockchainOption = .ethereum
    @Published var tags: [String] = []

    @Published var isSubmitting = false
    @Published var progress: Double = 0
    @Published var statusMessage: String = "准备生成"
    @Published var errorMessage: String?
    @Published var isShowingError = false

    private let dreamService = DreamService()
    private weak var appState: AppState?
    private var progressTask: Task<Void, Never>?

    deinit {
        progressTask?.cancel()
    }

    func bindAppState(_ appState: AppState) {
        self.appState = appState
    }

    var canResetForm: Bool {
        !title.isEmpty || !description.isEmpty || !tags.isEmpty || selectedMood != .serene || selectedStyle != .ethereal || selectedBlockchain != .ethereum
    }

    func goToStyling() {
        navigationPath = [.styling]
        syncCurrentStep()
    }

    func goToReview() {
        navigationPath = [.styling, .review]
        syncCurrentStep()
    }

    func goBack() {
        guard !navigationPath.isEmpty else { return }
        navigationPath.removeLast()
        syncCurrentStep()
        if currentStep != .progress {
            progressTask?.cancel()
        }
    }

    func submit() {
        guard !title.isEmpty, !description.isEmpty, !isSubmitting else { return }
        navigationPath = [.styling, .review, .progress]
        syncCurrentStep()
        progress = 0
        statusMessage = "正在提交梦境"
        isSubmitting = true
#if canImport(UIKit)
        HapticsManager.shared.impact()
#endif
        progressTask?.cancel()
        progressTask = Task {
            do {
                let request = DreamCreationRequest(
                    title: title,
                    description: description,
                    style: selectedStyle.rawValue,
                    mood: selectedMood.rawValue,
                    blockchain: selectedBlockchain,
                    tags: tags
                )

                let dream = try await dreamService.submitDream(request: request)
                statusMessage = "模型生成中"
                await appState?.refreshDreams()
                try await listenForProgress(of: dream)
            } catch {
                await handle(error: error)
            }
        }
    }

    func resetForm() {
        title = ""
        description = ""
        selectedMood = .serene
        selectedStyle = .ethereal
        selectedBlockchain = .ethereum
        tags = []
        resetProgress()
        navigationPath = []
        syncCurrentStep()
    }

    func finish() {
        resetForm()
    }

    func syncCurrentStep() {
        currentStep = navigationPath.last ?? .description
    }

    private func resetProgress() {
        progressTask?.cancel()
        progress = 0
        statusMessage = "准备生成"
        isSubmitting = false
    }

    private func listenForProgress(of dream: Dream) async throws {
        do {
            for try await event in dreamService.watchProgress(for: dream) {
                progress = event.progress
                statusMessage = event.message ?? event.status.localizedDescription
            }
            let finalDream = try await dreamService.refreshDream(id: dream.id)
            progress = finalDream.status == .completed ? 1 : progress
            statusMessage = finalDream.status.progressMessage
#if canImport(UIKit)
            if finalDream.status == .completed {
                HapticsManager.shared.notify(.success)
            } else if finalDream.status == .failed {
                HapticsManager.shared.notify(.error)
            }
#endif
            isSubmitting = false
            await appState?.refreshDreams()
        } catch {
            try Task.checkCancellation()
            throw error
        }
    }

    private func handle(error: Error) async {
        resetProgress()
        statusMessage = "生成失败"
        errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
#if canImport(UIKit)
        HapticsManager.shared.notify(.error)
#endif
        isShowingError = true
    }
}

enum Mood: String, CaseIterable, Identifiable {
    case serene = "宁静"
    case adventurous = "冒险"
    case mysterious = "神秘"
    case vibrant = "绚烂"

    var id: String { rawValue }
}

enum Style: String, CaseIterable, Identifiable {
    case ethereal = "空灵"
    case cyberpunk = "赛博朋克"
    case biomorphic = "仿生"
    case minimal = "极简"

    var id: String { rawValue }
}

private struct DreamDescriptionStep: View {
    @ObservedObject var viewModel: DreamCreationViewModel
    @State private var tagDraft = ""

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                StepProgressHeader(step: .description, activeStep: viewModel.currentStep)

                VStack(spacing: 18) {
                    TextField("梦境标题", text: $viewModel.title)
                        .textFieldStyle(.roundedBorder)

                    DreamEditor(text: $viewModel.description)

                    TagInputField(tags: $viewModel.tags, tagDraft: $tagDraft)
                }
                .padding(24)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                .glassBorder()

                PrimaryButton(title: "下一步", systemImage: "arrow.right") {
                    viewModel.goToStyling()
                }
                .disabled(viewModel.title.isEmpty || viewModel.description.isEmpty)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .background(GradientBackground())
    }
}

private struct DreamStylingStep: View {
    @ObservedObject var viewModel: DreamCreationViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                StepProgressHeader(step: .styling, activeStep: viewModel.currentStep)

                VStack(spacing: 16) {
                    PickerSection(title: "梦境情绪") {
                        Picker("情绪", selection: $viewModel.selectedMood) {
                            ForEach(Mood.allCases) { mood in
                                Text(mood.rawValue).tag(mood)
                            }
                        }
                        .pickerStyle(.segmented)
                    }

                    PickerSection(title: "艺术风格") {
                        Picker("风格", selection: $viewModel.selectedStyle) {
                            ForEach(Style.allCases) { style in
                                Text(style.rawValue).tag(style)
                            }
                        }
                        .pickerStyle(.segmented)
                    }

                    PickerSection(title: "区块链部署") {
                        Picker("链", selection: $viewModel.selectedBlockchain) {
                            ForEach(BlockchainOption.allCases) { option in
                                Text(option.displayName).tag(option)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                }
                .padding(24)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                .glassBorder()

                PrimaryButton(title: "确认设定", systemImage: "checkmark") {
                    viewModel.goToReview()
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .background(GradientBackground())
    }
}

private struct DreamReviewStep: View {
    @ObservedObject var viewModel: DreamCreationViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                StepProgressHeader(step: .review, activeStep: viewModel.currentStep)

                DreamSummaryCard(viewModel: viewModel)
                    .padding(.horizontal, 24)

                PrimaryButton(title: "提交生成", systemImage: "sparkles") {
                    viewModel.submit()
                }
                .disabled(viewModel.isSubmitting)
            }
            .padding(.bottom, 40)
        }
        .background(GradientBackground())
    }
}

private struct DreamProgressStep: View {
    @ObservedObject var viewModel: DreamCreationViewModel
    var appState: AppState
    var coordinator: NavigationCoordinator

    var body: some View {
        VStack(spacing: 28) {
            StepProgressHeader(step: .progress, activeStep: viewModel.currentStep)

            VStack(spacing: 24) {
                ProgressView(value: viewModel.progress)
                    .progressViewStyle(.linear)
                    .tint(.dreamechoAccent)
                ParticleBackground()
                    .frame(height: 160)
                    .mask(RoundedRectangle(cornerRadius: 24, style: .continuous))
                Text(viewModel.statusMessage)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(24)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
            .glassBorder()

            if !viewModel.isSubmitting {
                PrimaryButton(title: "查看梦境库", systemImage: "square.grid.2x2") {
                    Task { await appState.refreshDreams() }
                    viewModel.finish()
                    coordinator.switchTo(.library)
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 40)
        .background(GradientBackground())
    }
}

private struct StepProgressHeader: View {
    let step: DreamCreationStep
    let activeStep: DreamCreationStep

    var body: some View {
        VStack(spacing: 18) {
            DreamStepIndicator(activeStep: activeStep)
            VStack(spacing: 6) {
                Text(step.displayTitle)
                    .font(.title2.weight(.semibold))
                Text(step.detail)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

private struct DreamEditor: View {
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            TextEditor(text: $text)
                .frame(minHeight: 180)
                .background(Color.clear)
            Divider().background(Color.white.opacity(0.1))
            Text("可输入故事、画面、情感线索，越详细越好。")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

private struct TagInputField: View {
    @Binding var tags: [String]
    @Binding var tagDraft: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                TextField("添加标签（按下回车确认）", text: $tagDraft, onCommit: addTag)
                    .textFieldStyle(.roundedBorder)
                if !tagDraft.isEmpty {
                    Button("添加") { addTag() }
                        .buttonStyle(.borderedProminent)
                }
            }

            if !tags.isEmpty {
                FlowLayout(alignment: .leading, spacing: 8, minWidth: 80) {
                    ForEach(tags, id: \.self) { tag in
                        HStack(spacing: 6) {
                            Text(tag)
                                .font(.caption)
                            Image(systemName: "xmark")
                                .font(.system(size: 10, weight: .bold))
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.white.opacity(0.08))
                        .clipShape(Capsule())
                        .onTapGesture { remove(tag) }
                    }
                }
            }
        }
    }

    private func addTag() {
        let trimmed = tagDraft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !tags.contains(trimmed) else { return }
        tags.append(trimmed)
        tagDraft = ""
    }

    private func remove(_ tag: String) {
        tags.removeAll { $0 == tag }
    }
}

private struct PickerSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.callout.weight(.medium))
            content
        }
    }
}

private struct DreamSummaryCard: View {
    @ObservedObject var viewModel: DreamCreationViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text(viewModel.title)
                    .font(.title2).bold()
                Text(viewModel.description)
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }

            Divider().background(.white.opacity(0.2))

            Grid(horizontalSpacing: 18, verticalSpacing: 12) {
                GridRow {
                    Label("情绪", systemImage: "face.smiling")
                    Text(viewModel.selectedMood.rawValue)
                }
                GridRow {
                    Label("风格", systemImage: "paintbrush")
                    Text(viewModel.selectedStyle.rawValue)
                }
                GridRow {
                    Label("区块链", systemImage: "link")
                    Text(viewModel.selectedBlockchain.displayName)
                }
                if !viewModel.tags.isEmpty {
                    GridRow {
                        Label("标签", systemImage: "tag")
                        Text(viewModel.tags.joined(separator: "、"))
                    }
                }
            }
            .foregroundStyle(.secondary)
        }
        .padding(24)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .glassBorder()
    }
}


#Preview {
    DreamCreationFlow()
        .environmentObject(AppState())
        .environmentObject(NavigationCoordinator())
}
