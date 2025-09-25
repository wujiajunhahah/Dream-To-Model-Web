import SwiftUI

struct DreamLibraryView: View {
    @EnvironmentObject private var appState: AppState
    @State private var searchText = ""
    @State private var selectedSegment: LibrarySegment = .myDreams
    @State private var showErrorToast = false
    @State private var isRefreshing = false

    private var currentSource: [Dream] {
        switch selectedSegment {
        case .myDreams:
            return appState.completedDreams
        case .explore:
            return Dream.sampleCompleted
        }
    }

    private var filteredDreams: [Dream] {
        guard !searchText.isEmpty else { return currentSource }
        return currentSource.filter { dream in
            dream.title.localizedCaseInsensitiveContains(searchText) ||
            dream.description.localizedCaseInsensitiveContains(searchText) ||
            dream.tags.contains(where: { $0.localizedCaseInsensitiveContains(searchText) })
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    DreamLibraryHeader(
                        myCount: appState.completedDreams.count,
                        exploreCount: Dream.sampleCompleted.count,
                        pendingCount: appState.pendingDreams.count
                    )

                    Picker("梦境视图", selection: $selectedSegment) {
                        ForEach(LibrarySegment.allCases) { segment in
                            Text(segment.title).tag(segment)
                        }
                    }
                    .pickerStyle(.segmented)
                    .glassBorder()

                    if filteredDreams.isEmpty {
                        LibraryEmptyState(selectedSegment: selectedSegment)
                            .frame(maxWidth: .infinity)
                            .padding(.top, 40)
                    } else {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 220), spacing: 24)], spacing: 24) {
                            ForEach(filteredDreams) { dream in
                                DreamCard(dream: dream)
                                    .onTapGesture {
                                        appState.selectedDream = dream
                                        appState.isShowingARViewer = true
                                    }
                            }
                        }
                        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: filteredDreams)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 48)
                .padding(.top, 16)
            }
            .background(GradientBackground())
            .navigationTitle("梦境档案")
            .searchable(text: $searchText, prompt: "搜索梦境标题、关键字…")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        Task { await refreshDreams() }
                    } label: {
                        if isRefreshing {
                            ProgressView()
                        } else {
                            Label("刷新", systemImage: "arrow.clockwise")
                        }
                    }
                    .disabled(isRefreshing)
                }
            }
            .sheet(isPresented: $appState.isShowingARViewer) {
                if let dream = appState.selectedDream {
                    DreamDetailView(dream: dream)
                        .presentationDetents([.large])
                }
            }
        }
        .task { await refreshDreams() }
        .onChange(of: appState.lastError) { _, newValue in
            if newValue != nil { showErrorToast = true }
        }
        .toast(message: appState.lastError, isPresented: $showErrorToast)
    }

    private func refreshDreams() async {
        guard !isRefreshing else { return }
        isRefreshing = true
        await appState.refreshDreams()
        isRefreshing = false
    }
}

private enum LibrarySegment: String, CaseIterable, Identifiable {
    case myDreams
    case explore

    var id: String { rawValue }

    var title: String {
        switch self {
        case .myDreams: return "我的梦境"
        case .explore: return "灵感探索"
        }
    }
}

private struct DreamLibraryHeader: View {
    let myCount: Int
    let exploreCount: Int
    let pendingCount: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("捕捉你的灵感宇宙")
                .font(.largeTitle.weight(.semibold))
                .foregroundStyle(LinearGradient.dreamecho)

            HStack(spacing: 16) {
                LibraryStatCard(title: "已完成", value: myCount.description, subtitle: "梦境已生成")
                LibraryStatCard(title: "生成中", value: pendingCount.description, subtitle: "DreamSync 任务")
                LibraryStatCard(title: "灵感库", value: exploreCount.description, subtitle: "精选案例")
            }
        }
    }
}

private struct LibraryStatCard: View {
    let title: String
    let value: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.system(size: 32, weight: .bold, design: .rounded))
            Text(subtitle)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .glassBorder()
    }
}

private struct LibraryEmptyState: View {
    let selectedSegment: LibrarySegment

    var body: some View {
        VStack(spacing: 18) {
            Image(systemName: "sparkles.rectangle.stack")
                .font(.system(size: 44))
                .foregroundStyle(LinearGradient.dreamecho)
            Text(selectedSegment == .myDreams ? "还没有生成梦境" : "暂无灵感匹配")
                .font(.title3.weight(.semibold))
            Text(selectedSegment == .myDreams
                 ? "在梦境工坊描述你的第一个梦境，完成后会出现在这里。"
                 : "我们正在为你准备更多精选作品，请稍后再来。")
            .font(.callout)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: 360)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .glassBorder()
    }
}

private struct DreamCard: View {
    let dream: Dream

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            AsyncImage(url: dream.previewImageURL) { phase in
                switch phase {
                case .empty:
                    ZStack {
                        RoundedRectangle(cornerRadius: 24)
                            .fill(.ultraThinMaterial)
                        ProgressView()
                    }
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                case .failure:
                    RoundedRectangle(cornerRadius: 24)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            Image(systemName: "photo")
                                .font(.system(size: 32))
                                .foregroundStyle(.secondary)
                        )
                @unknown default:
                    EmptyView()
                }
            }
            .frame(height: 160)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))

            VStack(alignment: .leading, spacing: 10) {
                Text(dream.title)
                    .font(.headline)
                Text(dream.description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(3)

                if !dream.tags.isEmpty {
                    FlowLayout(alignment: .leading, spacing: 8) {
                        ForEach(dream.tags, id: \.self) { tag in
                            Text(tag)
                                .font(.caption)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(Color.white.opacity(0.08))
                                .clipShape(Capsule())
                        }
                    }
                }
            }

            HStack {
                Label(dream.blockchain.displayName, systemImage: "link")
                Spacer()
                Label(dream.status.localizedDescription, systemImage: dream.status.iconName)
            }
            .font(.footnote)
            .foregroundStyle(.secondary)
        }
        .padding(20)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
        .glassBorder(color: .white.opacity(0.18))
    }
}

private struct DreamDetailView: View {
    let dream: Dream
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    USDZViewer(url: dream.usdModelURL)
                        .frame(height: 320)
                        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                        .glassBorder()

                    VStack(alignment: .leading, spacing: 18) {
                        Text(dream.title)
                            .font(.largeTitle.weight(.bold))
                        Text(dream.description)
                            .foregroundStyle(.secondary)

                        Divider().background(.white.opacity(0.2))

                        InfoRow(label: "链", value: dream.blockchain.displayName, systemImage: "link")

                        if let price = dream.price {
                            InfoRow(label: "价格", value: "\(price)", systemImage: "creditcard")
                        }

                        if !dream.tags.isEmpty {
                            InfoRow(label: "标签", value: dream.tags.joined(separator: "、"), systemImage: "tag")
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                    .glassBorder()
                }
                .padding()
            }
            .background(GradientBackground())
            .navigationTitle("梦境详情")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("关闭") { dismiss() }
                }
                ToolbarItem(placement: .primaryAction) {
                    ShareLink(item: dream.usdModelURL ?? URL(string: "https://dreamecho.ai")!) {
                        Label("分享USDZ", systemImage: "square.and.arrow.up")
                    }
                }
            }
        }
    }
}

private struct InfoRow: View {
    let label: String
    let value: String
    let systemImage: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Label(label, systemImage: systemImage)
                .font(.subheadline.weight(.medium))
                .labelStyle(.iconOnly)
                .frame(width: 24)
                .foregroundStyle(LinearGradient.dreamecho)

            VStack(alignment: .leading, spacing: 4) {
                Text(label)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.body)
            }
        }
    }
}


#Preview {
    DreamLibraryView()
        .environmentObject(AppState())
}
