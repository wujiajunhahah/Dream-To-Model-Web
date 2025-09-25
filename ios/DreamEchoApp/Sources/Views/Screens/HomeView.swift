import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var appState: AppState

    private var hasPendingDreams: Bool { !appState.pendingDreams.isEmpty }
    private var hasCompletedDreams: Bool { !appState.completedDreams.isEmpty }

    var body: some View {
        ScrollView {
            VStack(spacing: 44) {
                HeroSection()
                DreamStatusStrip(pendingDreams: appState.pendingDreams, completedDreams: appState.completedDreams)
                PendingDreamCarousel(dreams: appState.pendingDreams)
                HighlightsGrid()
                ExplorePreview(dreams: hasCompletedDreams ? appState.completedDreams : Dream.sampleCompleted)
            }
            .padding(.vertical, 48)
            .padding(.horizontal, 24)
        }
        .background(
            ZStack {
                GradientBackground()
                ParticleBackground()
                LinearGradient(
                    gradient: Gradient(colors: [.clear, Color.black.opacity(0.3)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
            .ignoresSafeArea()
        )
        .task { await appState.refreshDreams() }
    }
}

private struct HeroSection: View {
    var body: some View {
        VStack(spacing: 32) {
            Capsule()
                .fill(.ultraThinMaterial)
                .overlay(
                    HStack(spacing: 10) {
                        Circle()
                            .fill(Color.dreamechoPrimary)
                            .frame(width: 10, height: 10)
                            .shadow(color: .dreamechoAccent.opacity(0.7), radius: 10)
                        Text("DreamEcho WWDC 特别版")
                            .font(.footnote.weight(.medium))
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal, 18)
                    .padding(.vertical, 10)
                )
                .glassBorder()

            VStack(spacing: 18) {
                Text("实时将梦境转化为 3D 模型")
                    .font(.system(size: 46, weight: .thin, design: .rounded))
                    .foregroundStyle(LinearGradient.dreamecho)
                    .multilineTextAlignment(.center)

                Text("从灵感捕捉、AI 解读到 USDZ 预览，DreamEcho 为创作者提供全链路的梦境工坊体验。")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)
            }

            HStack(spacing: 16) {
                PrimaryButton(title: "开启梦境工坊", systemImage: "sparkles") {
                    // Tab interaction handled by parent
                }

                SecondaryButton(title: "查看梦境库", systemImage: "square.grid.2x2") {
                    // Tab interaction handled by parent
                }
            }
            .frame(maxWidth: 640)
        }
    }
}

private struct DreamStatusStrip: View {
    let pendingDreams: [Dream]
    let completedDreams: [Dream]

    var body: some View {
        HStack(spacing: 18) {
            StatusTile(title: "DreamSync", value: pendingDreams.count.description, subtitle: "进行中的生成")
            StatusTile(title: "已完成", value: completedDreams.count.description, subtitle: "可随时预览")
            StatusTile(title: "灵感收藏", value: Dream.sampleCompleted.count.description, subtitle: "精选案例")
        }
    }
}

private struct StatusTile: View {
    let title: String
    let value: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.system(size: 30, weight: .bold, design: .rounded))
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

private struct PendingDreamCarousel: View {
    let dreams: [Dream]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "DreamSync 进行中", subtitle: "实时追踪生成进度")

            if dreams.isEmpty {
                GlassCardPlaceholder(
                    icon: "hourglass", title: "暂未创建任务",
                    message: "在梦境工坊提交描述后，这里会显示实时进度。"
                )
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 20) {
                        ForEach(dreams) { dream in
                            PendingDreamCard(dream: dream)
                        }
                    }
                }
            }
        }
    }
}

private struct PendingDreamCard: View {
    let dream: Dream

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(dream.title)
                .font(.headline)
            Text(dream.description)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(2)
            Divider().background(.white.opacity(0.15))
            Label(dream.status.progressMessage, systemImage: dream.status.iconName)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding(20)
        .frame(width: 240, alignment: .leading)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .glassBorder()
    }
}

private struct HighlightsGrid: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            SectionHeader(title: "创意工具箱", subtitle: "打造液态玻璃风格的关键组件")

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 200), spacing: 20)], spacing: 20) {
                HighlightCard(icon: "sparkles.rectangle.stack", title: "AI DreamScript", description: "DeepSeek 分析梦境文本，生成关键词、象征与叙事。")
                HighlightCard(icon: "cube.transparent", title: "Tripo 3D 引擎", description: "USDZ/GLB 实时预览，支持 AR QuickLook 与 RealityKit。")
                HighlightCard(icon: "paintpalette", title: "Liquid Glass UI", description: "SwiftUI + Material + 粒子背景打造沉浸式界面。")
                HighlightCard(icon: "cloud.upload", title: "Xcode Cloud", description: "CI/CD 自动化，保障 WWDC Demo 稳定上线。")
            }
        }
    }
}

private struct HighlightCard: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 28))
                .foregroundStyle(.white)
                .frame(width: 56, height: 56)
                .background(LinearGradient.dreamecho)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            Text(title)
                .font(.title3.weight(.semibold))
            Text(description)
                .font(.callout)
                .foregroundStyle(.secondary)
                .lineSpacing(4)
        }
        .padding(22)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .glassBorder()
    }
}

private struct ExplorePreview: View {
    let dreams: [Dream]

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            SectionHeader(title: "灵感探索", subtitle: "来自社区的精选梦境")

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 220), spacing: 20)], spacing: 20) {
                ForEach(dreams.prefix(3)) { dream in
                    ExploreCard(dream: dream)
                }
            }
        }
    }
}

private struct ExploreCard: View {
    let dream: Dream

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(.ultraThinMaterial)
                .frame(height: 140)
                .overlay(
                    VStack {
                        Image(systemName: "sparkles")
                            .font(.system(size: 36))
                            .foregroundStyle(LinearGradient.dreamecho)
                        Text("USDZ 预览")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                )

            VStack(alignment: .leading, spacing: 8) {
                Text(dream.title)
                    .font(.headline)
                Text(dream.description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
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
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .glassBorder(color: .white.opacity(0.18))
    }
}

private struct SectionHeader: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.title2.weight(.semibold))
            Text(subtitle)
                .font(.callout)
                .foregroundStyle(.secondary)
        }
    }
}

private struct GlassCardPlaceholder: View {
    let icon: String
    let title: String
    let message: String

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 36))
                .foregroundStyle(LinearGradient.dreamecho)
            Text(title)
                .font(.headline)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(32)
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .glassBorder()
    }
}

#Preview {
    HomeView()
        .environmentObject(AppState())
}
