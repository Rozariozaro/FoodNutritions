import SwiftUI

struct CalorieRingView: View {
    let current: Double
    let goal: Double
    var ringColor: Color = AppColors.primary
    var size: CGFloat = 160
    var lineWidth: CGFloat = 16

    private var progress: Double {
        guard goal > 0 else { return 0 }
        return min(current / goal, 1.0)
    }

    private var isOverGoal: Bool { current > goal }
    private var activeColor: Color { isOverGoal ? AppColors.error : ringColor }

    var body: some View {
        ZStack {
            Circle()
                .stroke(activeColor.opacity(0.12), lineWidth: lineWidth)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(activeColor, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.4), value: progress)

            VStack(spacing: 1) {
                Text(current, format: .number.precision(.fractionLength(0)))
                    .font(size < 100 ? AppTypography.subhead.bold() : AppTypography.title2.bold())
                    .foregroundStyle(isOverGoal ? AppColors.error : AppColors.textPrimary)
                    .contentTransition(.numericText())
                    .animation(.default, value: current)

                Text("/ \(Int(goal)) kcal")
                    .font(size < 100 ? AppTypography.caption1 : AppTypography.footnote)
                    .foregroundStyle(AppColors.textSecondary)
            }
        }
        .frame(width: size, height: size)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(Int(current)) of \(Int(goal)) kilocalories, \(Int(progress * 100)) percent\(isOverGoal ? ", over goal" : "")")
    }
}
