import SwiftUI

struct DreamLibraryView: View {
    @EnvironmentObject private var appState: AppState
    @State private var searchText = ""

    var filteredDreams: [Dream] {
        guard !searchText.isEmpty else { return appState.completedDreams }
        return appState.completedDreams.filter { dream in
            dream.title.localizedCaseInsensitiveContains(searchText) ||
            dream.description.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 200), spacing: 24)], spacing: 24) {
                    ForEach(filteredDreams) { dream in
                        DreamCard(dream: dream)
                            .onTapGesture {
                                appState.selectedDream = dream
                                appState.isShowingARViewer = true
                            }
                    }
                }
                .padding()
            }
            .background(GradientBackground())
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
            .navigationTitle("梦境库")
            .sheet(isPresented: $appState.isShowingARViewer) {
                if let dream = appState.selectedDream {
                    DreamDetailView(dream: dream)
                }
            }
        }
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
                        .overlay(Image(systemName: "photo")
                            .font(.system(size: 32))
                            .foregroundStyle(.secondary))
                @unknown default:
                    EmptyView()
                }
            }
            .frame(height: 160)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))

            VStack(alignment: .leading, spacing: 8) {
                Text(dream.title)
                    .font(.headline)
                Text(dream.description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(3)
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

private extension DreamStatus {
    var localizedDescription: String {
        switch self {
        case .pending: return "待处理"
        case .processing: return "生成中"
        case .completed: return "已完成"
        case .failed: return "失败"
        }
    }

    var iconName: String {
        switch self {
        case .pending: return "clock"
        case .processing: return "hourglass"
        case .completed: return "checkmark.seal"
        case .failed: return "exclamationmark.triangle"
        }
    }
}

private struct DreamDetailView: View {
    let dream: Dream

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                USDZViewer(url: dream.usdModelURL)
                    .frame(height: 320)
                    .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                    .glassBorder()

                VStack(alignment: .leading, spacing: 16) {
                    Text(dream.title)
                        .font(.largeTitle.weight(.bold))
                    Text(dream.description)
                        .foregroundStyle(.secondary)

                    HStack {
                        Label("链", systemImage: "link")
                        Text(dream.blockchain.displayName)
                    }

                    if let price = dream.price {
                        HStack {
                            Label("价格", systemImage: "dollarsign")
                            Text("\(price)")
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                .glassBorder()
            }
            .padding()
            .background(GradientBackground())
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    ShareLink(item: dream.usdModelURL ?? URL(string: "https://dreamecho.ai")!) {
                        Label("分享USDZ", systemImage: "square.and.arrow.up")
                    }
                }
            }
        }
    }
}

#Preview {
    DreamLibraryView()
        .environmentObject(AppState())
}
