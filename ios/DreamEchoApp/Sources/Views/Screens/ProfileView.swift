import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var appState: AppState
    @State private var isDarkMode = true
    @State private var emailNotifications = true
    @State private var animationsEnabled = true

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("账户")) {
                    if let user = appState.session?.user {
                        LabeledContent("用户名") { Text(user.username) }
                        LabeledContent("邮箱") { Text(user.email) }
                    }
                }

                Section(header: Text("偏好")) {
                    Toggle("深色模式", isOn: $isDarkMode)
                    Toggle("邮件通知", isOn: $emailNotifications)
                    Toggle("粒子动画", isOn: $animationsEnabled)
                }

                Section(header: Text("关于DreamEcho")) {
                    NavigationLink("体验指南") {
                        ExperienceGuideView()
                    }
                    NavigationLink("隐私政策") {
                        Text("TODO: 添加隐私政策内容")
                            .foregroundStyle(.secondary)
                    }
                }

                Section {
                    Button(role: .destructive) {
                        // TODO: logout flow
                    } label: {
                        Label("退出登录", systemImage: "rectangle.portrait.and.arrow.right")
                    }
                }
            }
            .background(GradientBackground())
            .navigationTitle("个人中心")
        }
    }
}

private struct ExperienceGuideView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("DreamEcho 体验指南")
                    .font(.largeTitle.weight(.bold))
                    .foregroundStyle(LinearGradient.dreamecho)

                Text("1. 使用自然语言描述你的梦境，系统会自动生成DreamScript并调用DeepSeek与Tripo API完成模型。")
                Text("2. DreamSync 状态中心提供实时进度提醒，完成后可直接进入USDZ实时预览或AR模式。")
                Text("3. DreamVault 会自动整理你的梦境档案，支持筛选、标签和分享。")
            }
            .padding()
        }
        .background(GradientBackground())
    }
}

#Preview {
    ProfileView()
        .environmentObject(AppState())
}
