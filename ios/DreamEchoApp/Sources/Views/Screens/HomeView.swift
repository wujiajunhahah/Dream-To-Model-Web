import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var coordinator: NavigationCoordinator

    private var hasCompletedDreams: Bool { !appState.completedDreams.isEmpty }
    private var hasPendingDreams: Bool { !appState.pendingDreams.isEmpty }

    var body: some View {
        ScrollView {
            VStack(spacing: 44) {
                HeroSection(onCreate: { coordinator.switchTo(.creation) }, onLibrary: { coordinator.switchTo(.library) })
                StatusHighlights(pending: appState.pendingDreams, completed: appState.completedDreams)
                PendingCarousel(dreams: hasPendingDreams ? appState.pendingDreams : Dream.pendingSamples)
                ToolingGrid()
                ExplorePreview(dreams: hasCompletedDreams ? appState.completedDreams : Dream.showcase)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 48)
        }
        .background(
            ZStack {
                LinearGradient(colors: [.dreamechoBackground, Color.black], startPoint: .topLeading, endPoint: .bottomTrailing)
                ParticleBackground()
            }
            .ignoresSafeArea()
        )
    }
}

private struct HeroSection: View {
    let onCreate: () -> Void
    let onLibrary: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Capsule()
                .fill(.ultraThinMaterial)
                .overlay(
                    HStack(spacing: 10) {
                        Circle()
                            .fill(Color.dreamechoPrimary)
                            .frame(width: 10, height: 10)
                            .shadow(color: .dreamechoSecondary.opacity(0.8), radius: 10)
                        Text("DreamEcho · WWDC Demo Studio")
                            .font(.footnote.weight(.medium))
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal, 18)
                    .padding(.vertical, 10)
                )
                .glassBorder(cornerRadius: 40)

            VStack(spacing: 16) {
                Text("你的梦境，实时生成 3D 艺术")
                    .font(AppFont.heading(44))
                    .foregroundStyle(LinearGradient.dreamecho)
                    .multilineTextAlignment(.center)

                Text("描述、风格设定、链上发布，全流程无缝衔接。Liquid Glass UI 让 DreamSync 进度一目了然。")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)
            }

            HStack(spacing: 16) {
                Button(action: onCreate) {
                    Label("开启梦境工坊", systemImage: "sparkles")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 28)
                        .padding(.vertical, 16)
                        .background(LinearGradient.dreamecho)
                        .clipShape(Capsule())
                        .shadow(color: .dreamechoPrimary.opacity(0.4), radius: 16, y: 8)
                }

                Button(action: onLibrary) {
                    Label("查看梦境库", systemImage: "square.grid.2x2")
                        .font(.headline)
                }
                .buttonStyle(GlassButtonStyle())
            }
        }
    }
}

private struct StatusHighlights: View {
    let pending: [Dream]
    let completed: [Dream]

    var body: some View {
        HStack(spacing: 18) {
            HighlightTile(title: "DreamSync", value: pending.count, caption: "进行中的生成")
            HighlightTile(title: "已完成", value: completed.count, caption: "可 USDZ 预览")
            HighlightTile(title: "灵感库", value: Dream.showcase.count, caption: "精选案例")
        }
    }
}

private struct HighlightTile: View {
    let title: String
    let value: Int
    let caption: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.caption).foregroundStyle(.secondary)
            Text("\(value)").font(AppFont.heading(30))
            Text(caption).font(.caption).foregroundStyle(.secondary)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
        .glassBorder()
    }
}

private struct PendingCarousel: View {
    let dreams: [Dream]

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            SectionHeader(title: "DreamSync 进度", subtitle: "实时追踪生成状态")
            if dreams.isEmpty {
                GlassPlaceholder(icon: "hourglass", title: "暂无任务", message: "在梦境工坊提交描述后将自动显示进度。")
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 20) {
                        ForEach(dreams) { dream in
                            PendingCard(dream: dream)
                        }
                    }
                }
            }
        }
    }
}

private struct PendingCard: View {
    let dream: Dream

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(dream.title).font(.headline)
            Text(dream.description)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(2)
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

private struct ToolingGrid: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            SectionHeader(title: "创意工具箱", subtitle: "关键系统概览")
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 200), spacing: 18)], spacing: 18) {
                ToolCard(icon: "cpu", title: "DeepSeek AI", description: "解析梦境语义，输出 DreamScript 与情绪标签。")
                ToolCard(icon: "cube.transparent", title: "Tripo 3D", description: "驱动 USDZ/GLB 生成功能，支持 AR 预览。")
                ToolCard(icon: "paintpalette", title: "Liquid Glass UI", description: "渐层玻璃界面与粒子背景保持沉浸体验。")
                ToolCard(icon: "cloud", title: "Xcode Cloud", description: "集成 CI/CD 与 TestFlight，保障 WWDC 演示稳定。")
            }
        }
    }
}

private struct ToolCard: View {
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
            Text(title).font(.title3.weight(.semibold))
            Text(description).font(.callout).foregroundStyle(.secondary)
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
            SectionHeader(title: "灵感探索", subtitle: "来自创作者的精选梦境")
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
                    VStack(spacing: 6) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 34))
                            .foregroundStyle(LinearGradient.dreamecho)
                        Text("USDZ 预览")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                )
            VStack(alignment: .leading, spacing: 8) {
                Text(dream.title).font(.headline)
                Text(dream.description).font(.subheadline).foregroundStyle(.secondary).lineLimit(2)
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
        .glassBorder()
    }
}

private struct SectionHeader: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.title3.weight(.semibold))
            Text(subtitle).font(.callout).foregroundStyle(.secondary)
        }
    }
}

private struct GlassPlaceholder: View {
    let icon: String
    let title: String
    let message: String

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon).font(.system(size: 34)).foregroundStyle(LinearGradient.dreamecho)
            Text(title).font(.headline)
            Text(message).font(.subheadline).foregroundStyle(.secondary).multilineTextAlignment(.center)
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
        .environmentObject(NavigationCoordinator())
}
