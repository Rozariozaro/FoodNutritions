import SwiftUI

struct MacroProgressBar: View {
    let label: String
    let current: Double
    let goal: Double
    var color: Color = .blue
    var unit: String = "g"

    private var progress: Double {
        guard goal > 0 else { return 0 }
        return min(current / goal, 1.0)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(label)
                    .font(.subheadline.weight(.medium))
                Spacer()
                Text(String(format: "%.1f / %.0f%@", current, goal, unit))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            ProgressView(value: progress)
                .progressViewStyle(.linear)
                .tint(color)
        }
    }
}
