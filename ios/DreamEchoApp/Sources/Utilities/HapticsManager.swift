import Foundation
#if canImport(UIKit)
import UIKit

final class HapticsManager {
    static let shared = HapticsManager()

    private let notificationGenerator = UINotificationFeedbackGenerator()
    private let impactGenerator = UIImpactFeedbackGenerator(style: .medium)

    private init() {}

    func notify(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        notificationGenerator.prepare()
        notificationGenerator.notificationOccurred(type)
    }

    func impact() {
        impactGenerator.prepare()
        impactGenerator.impactOccurred()
    }
}
#endif
