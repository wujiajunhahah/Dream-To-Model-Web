import SwiftUI

struct HomeView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 40) {
                HeroSection()
                FeatureGrid()
                DreamShowcase()
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
    }
}

private struct HeroSection: View {
    var body: some View {
        VStack(spacing: 24) {
            Capsule()
                .fill(.ultraThinMaterial)
                .overlay(
                    HStack(spacing: 10) {
                        Circle()
                            .fill(Color.dreamechoPrimary)
                            .frame(width: 10, height: 10)
                            .shadow(color: .dreamechoAccent.opacity(0.7), radius: 10)
                        Text("DreamEcho - 梦境工艺设计工作室")
                            .font(.footnote.weight(.medium))
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal, 18)
                    .padding(.vertical, 10)
                )
                .glassBorder()

            VStack(spacing: 16) {
                Text("将你的\n梦境转化\n为独特的3D艺术")
                    .font(.system(size: 48, weight: .thin, design: .rounded))
                    .foregroundStyle(
                        LinearGradient.dreamecho
                    )
                    .multilineTextAlignment(.center)

                Text("通过先进的AI技术，我们将你的梦境转化为独特的3D艺术作品。每个梦境都成为独一无二的NFT，永久存储在区块链上。")
                    .font(.system(.title3, design: .rounded))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)
                    .padding(.horizontal)
            }

            HStack(spacing: 16) {
                PrimaryButton(title: "开始创建梦境", systemImage: "sparkles") {
                    // Navigate to creation flow (handled by parent view)
                }

                SecondaryButton(title: "探索梦境库", systemImage: "arrow.right") {
                    // Navigate to dream library
                }
            }
            .frame(maxWidth: 620)
        }
    }
}

private struct FeatureGrid: View {
    let features: [Feature] = Feature.all

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 260), spacing: 24)], spacing: 24) {
            ForEach(features) { feature in
                VStack(alignment: .leading, spacing: 18) {
                    feature.icon
                        .font(.system(size: 30))
                        .foregroundStyle(.white)
                        .frame(width: 64, height: 64)
                        .background(feature.gradient)
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                        .shadow(color: feature.shadowColor.opacity(0.3), radius: 12, y: 6)

                    Text(feature.title)
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(.primary)

                    Text(feature.subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineSpacing(4)
                }
                .padding(24)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                .glassBorder(color: feature.shadowColor.opacity(0.25))
            }
        }
    }
}

private struct DreamShowcase: View {
    @State private var isAnimating = false

    var body: some View {
        RoundedRectangle(cornerRadius: 36, style: .continuous)
            .fill(.ultraThinMaterial)
            .overlay(
                VStack(spacing: 30) {
                    Text("3D梦境展示")
                        .font(.largeTitle.weight(.semibold))
                        .foregroundStyle(LinearGradient.dreamecho)

                    USDZViewer(url: Bundle.main.url(forResource: "DreamStatue", withExtension: "usdz"))
                        .frame(height: 280)
                        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))

                    Text("即将展示您的梦境3D模型")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                        .padding(.bottom, 12)
                }
                .padding(32)
            )
            .glassBorder()
            .shadow(color: .black.opacity(0.15), radius: 30, y: 18)
    }
}

private struct Feature: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let icon: Image
    let gradient: LinearGradient
    let shadowColor: Color

    static let all: [Feature] = [
        .init(
            title: "AI梦境生成",
            subtitle: "通过自然语言描述快速生成高精度3D模型。",
            icon: Image(systemName: "wand.and.stars"),
            gradient: LinearGradient(colors: [.dreamechoPrimary, .dreamechoAccent], startPoint: .topLeading, endPoint: .bottomTrailing),
            shadowColor: .dreamechoPrimary
        ),
        .init(
            title: "NFT多链交易",
            subtitle: "支持Ethereum、Polygon等主流公链NFT铸造与交易。",
            icon: Image(systemName: "link.circle"),
            gradient: LinearGradient(colors: [.purple, .blue], startPoint: .topLeading, endPoint: .bottomTrailing),
            shadowColor: .purple
        ),
        .init(
            title: "沉浸式体验",
            subtitle: "粒子背景与实时渲染营造梦境氛围。",
            icon: Image(systemName: "theatermasks"),
            gradient: LinearGradient(colors: [.pink, .orange], startPoint: .topLeading, endPoint: .bottomTrailing),
            shadowColor: .pink
        ),
        .init(
            title: "跨设备同步",
            subtitle: "自动同步梦境档案，随时随地唤起灵感。",
            icon: Image(systemName: "rectangle.2.swap"),
            gradient: LinearGradient(colors: [.cyan, .mint], startPoint: .topLeading, endPoint: .bottomTrailing),
            shadowColor: .mint
        ),
        .init(
            title: "创作者社区",
            subtitle: "分享与交流，探索梦境艺术的无限可能。",
            icon: Image(systemName: "person.3.fill"),
            gradient: LinearGradient(colors: [.indigo, .blue], startPoint: .topLeading, endPoint: .bottomTrailing),
            shadowColor: .indigo
        ),
        .init(
            title: "多格式导出",
            subtitle: "导出USDZ/GLB/OBJ格式，轻松融入其他工作流。",
            icon: Image(systemName: "square.and.arrow.down"),
            gradient: LinearGradient(colors: [.teal, .blue], startPoint: .topLeading, endPoint: .bottomTrailing),
            shadowColor: .teal
        )
    ]
}

#Preview {
    HomeView()
}
