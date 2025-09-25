import SwiftUI

struct FlowLayout<Content: View>: View {
    let alignment: HorizontalAlignment
    let spacing: CGFloat
    let minWidth: CGFloat
    @ViewBuilder private let content: () -> Content

    init(alignment: HorizontalAlignment = .leading, spacing: CGFloat = 8, minWidth: CGFloat = 70, @ViewBuilder content: @escaping () -> Content) {
        self.alignment = alignment
        self.spacing = spacing
        self.minWidth = minWidth
        self.content = content
    }

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: minWidth), spacing: spacing)], alignment: alignment, spacing: spacing) {
            content()
        }
    }
}
