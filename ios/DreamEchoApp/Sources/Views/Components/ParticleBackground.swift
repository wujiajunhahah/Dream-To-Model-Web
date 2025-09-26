import SwiftUI

struct ParticleBackground: View {
    var body: some View {
        TimelineView(.animation) { context in
            Canvas { canvas, size in
                let time = context.date.timeIntervalSinceReferenceDate
                let particles = 120
                for index in 0..<particles {
                    var position = CGPoint(
                        x: size.width * CGFloat((Double(index) / Double(particles)) + 0.2 * sin(time + Double(index))),
                        y: size.height * CGFloat((Double(index % 7) / 7.0))
                    )
                    position.x = position.x.truncatingRemainder(dividingBy: size.width)
                    position.y += CGFloat(sin(time + Double(index))) * 24

                    var circle = canvas.resolve(Image(systemName: "circle.fill"))
                    circle.shading = .color(.white.opacity(0.18))
                    canvas.addFilter(.blur(radius: 2))
                    canvas.draw(circle, at: position)
                }
            }
        }
        .allowsHitTesting(false)
    }
}
