import SwiftUI

struct ParticleBackground: View {
    @State private var time: CGFloat = 0

    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let elapsed = timeline.date.timeIntervalSinceReferenceDate
                time = CGFloat(elapsed.truncatingRemainder(dividingBy: 120))

                for index in 0..<120 {
                    var position = CGPoint(
                        x: CGFloat.random(in: 0...size.width),
                        y: CGFloat.random(in: 0...size.height)
                    )

                    let progress = CGFloat(index) / 120 + time * 0.005
                    position.x = size.width * (progress.truncatingRemainder(dividingBy: 1))
                    position.y += sin(progress * .pi * 2) * 40

                    var particle = context.resolve(
                        Image(systemName: "circle.fill")
                    )

                    context.opacity = 0.25
                    context.addFilter(.blur(radius: 2))
                    context.draw(particle, at: position, anchor: .center)
                }
            }
        }
        .blur(radius: 8)
        .allowsHitTesting(false)
    }
}
