import SwiftUI

struct CalorieRingView: View {
    let current: Double
    let goal: Double
    var ringColor: Color = .orange
    var size: CGFloat = 160
    var lineWidth: CGFloat = 16

    private var progress: Double {
        guard goal > 0 else { return 0 }
        return min(current / goal, 1.0)
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(ringColor.opacity(0.2), lineWidth: lineWidth)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(ringColor, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.4), value: progress)

            VStack(spacing: 2) {
                Text(String(format: "%.0f", current))
                    .font(.title2.bold())
                Text("/ \(Int(goal)) kcal")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: size, height: size)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(Int(current)) of \(Int(goal)) kilocalories, \(Int(progress * 100)) percent")
    }
}
