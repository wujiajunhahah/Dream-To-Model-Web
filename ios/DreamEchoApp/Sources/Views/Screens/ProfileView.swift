import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var appState: AppState
    @State private var enableNotifications = true
    @State private var enableHaptics = true

    var body: some View {
        NavigationStack {
            Form {
                if let user = appState.session?.user {
                    Section("账户") {
                        LabeledContent("用户名", value: user.username)
                        LabeledContent("邮箱", value: user.email)
                    }
                }

                Section("体验设置") {
                    Toggle("启用通知", isOn: $enableNotifications)
                    Toggle("启用触感反馈", isOn: $enableHaptics)
                }

                Section("系统") {
                    Button("同步梦境") {
                        Task { await appState.refreshDreams() }
                    }
                    Button("退出登录", role: .destructive) {
                        Task { await appState.logout() }
                    }
                }
            }
            .navigationTitle("个人中心")
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(AppState())
}
