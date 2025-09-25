import SwiftUI

extension Color {
    static let dreamechoPrimary = Color(red: 0.44, green: 0.38, blue: 0.98)
    static let dreamechoAccent = Color(red: 0.34, green: 0.85, blue: 0.96)
    static let dreamechoDark = Color(red: 0.06, green: 0.07, blue: 0.15)
    static let dreamechoGlassBorder = Color.white.opacity(0.25)
}

extension LinearGradient {
    static let dreamecho = LinearGradient(
        gradient: Gradient(colors: [.dreamechoPrimary, .dreamechoAccent]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

enum DreamEchoShadow {
    static let card = Shadow(color: .black.opacity(0.12), radius: 20, x: 0, y: 12)
}

struct Shadow {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}

struct GradientBackground: View {
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [.dreamechoDark, Color.black]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

struct PrimaryButton: View {
    let title: String
    let systemImage: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
                .font(.headline)
                .padding(.horizontal, 28)
                .padding(.vertical, 16)
                .background(LinearGradient.dreamecho)
                .foregroundColor(.white)
                .clipShape(Capsule())
                .shadow(color: Color.dreamechoPrimary.opacity(0.35), radius: 16, y: 8)
        }
    }
}

struct SecondaryButton: View {
    let title: String
    let systemImage: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
                .font(.headline)
                .padding(.horizontal, 28)
                .padding(.vertical, 16)
                .background(.ultraThinMaterial)
                .foregroundColor(.white)
                .clipShape(Capsule())
                .glassBorder()
        }
    }
}

struct GlassBorderModifier: ViewModifier {
    var color: Color = .dreamechoGlassBorder

    func body(content: Content) -> some View {
        content
            .overlay(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .stroke(color, lineWidth: 1.2)
                    .blendMode(.overlay)
            )
    }
}

extension View {
    func glassBorder(color: Color = .dreamechoGlassBorder) -> some View {
        modifier(GlassBorderModifier(color: color))
    }
}
