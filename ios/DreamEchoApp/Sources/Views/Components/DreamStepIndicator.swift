import SwiftUI

struct DreamStepIndicator: View {
    let activeStep: DreamCreationStep

    var body: some View {
        HStack(spacing: 16) {
            ForEach(DreamCreationStep.allCases, id: \.self) { step in
                StepIndicatorItem(step: step, isActive: step == activeStep, isCompleted: step.rawValue < activeStep.rawValue)

                if step != DreamCreationStep.allCases.last {
                    Rectangle()
                        .fill(.white.opacity(0.2))
                        .frame(height: 1)
                        .overlay(
                            LinearGradient.dreamecho
                                .opacity(step.rawValue < activeStep.rawValue ? 1 : 0.3)
                        )
                }
            }
        }
        .padding(.horizontal, 12)
    }
}

private struct StepIndicatorItem: View {
    let step: DreamCreationStep
    let isActive: Bool
    let isCompleted: Bool

    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .fill(isActive ? LinearGradient.dreamecho : Color.white.opacity(0.06))
                    .frame(width: 32, height: 32)
                    .overlay(
                        Circle()
                            .stroke(isCompleted ? LinearGradient.dreamecho : Color.white.opacity(0.2), lineWidth: 1.5)
                    )

                if isCompleted {
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                } else {
                    Text("\(step.rawValue + 1)")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(isActive ? .white : .white.opacity(0.6))
                }
            }

            Text(step.displayTitle)
                .font(.caption2)
                .foregroundStyle(isActive ? LinearGradient.dreamecho : .secondary)
        }
    }
}

#Preview {
    DreamStepIndicator(activeStep: .review)
        .padding()
        .background(GradientBackground())
}
