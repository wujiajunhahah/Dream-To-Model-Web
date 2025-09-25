import SwiftUI

struct DreamCreationFlow: View {
    @EnvironmentObject private var appState: AppState
    @StateObject private var viewModel = DreamCreationViewModel()

    var body: some View {
        NavigationStack(path: $viewModel.navigationPath) {
            DreamDescriptionStep(viewModel: viewModel)
                .navigationDestination(for: DreamCreationStep.self) { step in
                    switch step {
                    case .description:
                        DreamDescriptionStep(viewModel: viewModel)
                    case .styling:
                        DreamStylingStep(viewModel: viewModel)
                    case .review:
                        DreamReviewStep(viewModel: viewModel)
                    case .progress:
                        DreamProgressStep(viewModel: viewModel)
                    }
                }
                .navigationTitle("梦境工坊")
                .toolbarBackground(.visible, for: .navigationBar)
                .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
        }
        .toast(message: viewModel.errorMessage, isPresented: $viewModel.isShowingError)
        .task {
            viewModel.bindAppState(appState)
        }
    }
}

enum DreamCreationStep: Hashable {
    case description
    case styling
    case review
    case progress
}

@MainActor
final class DreamCreationViewModel: ObservableObject {
    @Published var navigationPath: [DreamCreationStep] = []
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

    func goToStyling() {
        navigationPath.append(.styling)
    }

    func goToReview() {
        navigationPath.append(.review)
    }

    func submit() {
        guard !title.isEmpty, !description.isEmpty else { return }
        navigationPath.append(.progress)
        progress = 0
        statusMessage = "正在提交梦境"
        isSubmitting = true

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

    private func listenForProgress(of dream: Dream) async throws {
        do {
            for try await event in dreamService.watchProgress(for: dream) {
                progress = event.progress
                statusMessage = event.message ?? event.status.localizedDescription
            }
            let finalDream = try await dreamService.refreshDream(id: dream.id)
            progress = finalDream.status == .completed ? 1 : progress
            statusMessage = finalDream.status.progressMessage
            isSubmitting = false
            await appState?.refreshDreams()
        } catch {
            try Task.checkCancellation()
            throw error
        }
    }

    private func handle(error: Error) async {
        isSubmitting = false
        progress = 0
        statusMessage = "生成失败"
        errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
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

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                StepHeader(title: "描述梦境")

                TextField("梦境标题", text: $viewModel.title)
                    .textFieldStyle(.roundedBorder)

                TextEditor(text: $viewModel.description)
                    .frame(minHeight: 180)
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .glassBorder()

                PrimaryButton(title: "下一步", systemImage: "arrow.right") {
                    viewModel.goToStyling()
                }
                .disabled(viewModel.title.isEmpty || viewModel.description.isEmpty)
            }
            .padding()
        }
        .background(GradientBackground())
    }
}

private struct DreamStylingStep: View {
    @ObservedObject var viewModel: DreamCreationViewModel

    var body: some View {
        Form {
            Section(header: Text("梦境情绪")) {
                Picker("情绪", selection: $viewModel.selectedMood) {
                    ForEach(Mood.allCases) { mood in
                        Text(mood.rawValue).tag(mood)
                    }
                }
                .pickerStyle(.segmented)
            }

            Section(header: Text("艺术风格")) {
                Picker("风格", selection: $viewModel.selectedStyle) {
                    ForEach(Style.allCases) { style in
                        Text(style.rawValue).tag(style)
                    }
                }
                .pickerStyle(.segmented)
            }

            Section(header: Text("区块链")) {
                Picker("链", selection: $viewModel.selectedBlockchain) {
                    ForEach(BlockchainOption.allCases) { option in
                        Text(option.displayName).tag(option)
                    }
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(GradientBackground())
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                PrimaryButton(title: "确认", systemImage: "checkmark") {
                    viewModel.goToReview()
                }
            }
        }
    }
}

private struct DreamReviewStep: View {
    @ObservedObject var viewModel: DreamCreationViewModel

    var body: some View {
        VStack(spacing: 18) {
            StepHeader(title: "确认梦境详情")

            DreamSummaryCard(viewModel: viewModel)

            PrimaryButton(title: "提交生成", systemImage: "sparkles") {
                viewModel.submit()
            }
            .disabled(viewModel.isSubmitting)
        }
        .padding()
        .background(GradientBackground())
    }
}

private struct DreamProgressStep: View {
    @ObservedObject var viewModel: DreamCreationViewModel

    var body: some View {
        VStack(spacing: 24) {
            StepHeader(title: "DreamSync 生成中")
            ProgressView(value: viewModel.progress)
                .progressViewStyle(.linear)
                .padding(.horizontal)
            ParticleBackground()
                .frame(height: 160)
                .mask(RoundedRectangle(cornerRadius: 24, style: .continuous))
            Text(viewModel.statusMessage)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(GradientBackground())
    }
}

private struct StepHeader: View {
    let title: String

    var body: some View {
        VStack(spacing: 12) {
            Text(title)
                .font(.largeTitle.weight(.semibold))
                .foregroundStyle(LinearGradient.dreamecho)
            Text("保持屏幕常亮，实时掌握梦境生成进度。")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
    }
}

private struct DreamSummaryCard: View {
    @ObservedObject var viewModel: DreamCreationViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(viewModel.title)
                        .font(.title).bold()
                    Text(viewModel.description)
                        .font(.body)
                        .foregroundStyle(.secondary)
                }
                Spacer()
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
            }
            .foregroundStyle(.secondary)
        }
        .padding(24)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .glassBorder()
    }
}

extension DreamStatus {
    var progressMessage: String {
        switch self {
        case .pending, .processing:
            return "模型生成进行中"
        case .completed:
            return "生成完成"
        case .failed:
            return "生成失败"
        }
    }
}

#Preview {
    DreamCreationFlow()
        .environmentObject(AppState())
}
