// See also: Core/DesignTokens/MacroProgressBar.swift (simpler value/color/label API)
import SwiftUI

struct MacroProgressBar: View {
    let label: String
    let current: Double
    let goal: Double
    var color: Color = AppColors.protein
    var unit: String = "g"

    private var progress: Double {
        guard goal > 0 else { return 0 }
        return min(current / goal, 1.0)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            HStack {
                Text(label)
                    .font(AppTypography.subhead.weight(.medium))
                Spacer()
                Text(String(format: "%.1f / %.0f%@", current, goal, unit))
                    .font(AppTypography.caption1)
                    .foregroundStyle(AppColors.textSecondary)
            }
            ProgressView(value: progress)
                .progressViewStyle(.linear)
                .tint(color)
                .animation(.easeInOut(duration: 0.3), value: progress)
        }
    }
}
