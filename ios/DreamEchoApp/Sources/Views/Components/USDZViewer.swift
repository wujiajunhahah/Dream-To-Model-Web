import SwiftUI
import QuickLook
import ARKit

struct USDZViewer: View {
    let url: URL?

    @State private var isPresented = false

    var body: some View {
        Group {
            if let url {
                RealityPreview(url: url)
                    .onTapGesture {
                        isPresented.toggle()
                    }
                    .sheet(isPresented: $isPresented) {
                        QuickLookPreview(url: url)
                    }
            } else {
                Placeholder()
            }
        }
    }

    private struct Placeholder: View {
        var body: some View {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    VStack(spacing: 12) {
                        ProgressView()
                            .progressViewStyle(.circular)
                        Text("正在加载USDZ模型")
                            .foregroundStyle(.secondary)
                    }
                )
        }
    }
}

private struct RealityPreview: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> ARView {
        let view = ARView(frame: .zero)
        view.environment.background = .color(.black)
        Task {
            await loadModel(into: view)
        }
        return view
    }

    func updateUIView(_ uiView: ARView, context: Context) {}

    private func loadModel(into view: ARView) async {
        do {
            let entity = try await ModelEntity.loadAsync(contentsOf: url)
            let anchor = AnchorEntity(.plane(.horizontal, classification: .any, minimumBounds: SIMD2<Float>(0.2, 0.2)))
            anchor.scale = SIMD3<Float>(repeating: 0.6)
            anchor.addChild(entity)
            view.scene.anchors.removeAll()
            view.scene.addAnchor(anchor)
        } catch {
            print("USDZ load failed: \(error)")
        }
    }
}

private struct QuickLookPreview: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> QLPreviewController {
        let controller = QLPreviewController()
        controller.dataSource = context.coordinator
        return controller
    }

    func updateUIViewController(_ controller: QLPreviewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(url: url)
    }

    final class Coordinator: NSObject, QLPreviewControllerDataSource {
        private let item: PreviewItem

        init(url: URL) {
            self.item = PreviewItem(url: url)
        }

        func numberOfPreviewItems(in controller: QLPreviewController) -> Int { 1 }

        func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
            item
        }

        private final class PreviewItem: NSObject, QLPreviewItem {
            let previewItemURL: URL?

            init(url: URL) {
                self.previewItemURL = url
            }
        }
    }
}
