import SwiftUI

struct NutritionMacroHeader: View {
    let calories: Double
    let protein: Double
    let carbs: Double
    let fat: Double

    var body: some View {
        HStack(spacing: AppSpacing.xl) {
            CalorieRingView(
                current: calories,
                goal: NutritionGoals.calories,
                size: 140
            )

            VStack(alignment: .leading, spacing: AppSpacing.smMd) {
                macroRow(label: "Protein", value: protein, goal: NutritionGoals.protein, color: AppColors.protein)
                macroRow(label: "Carbs", value: carbs, goal: NutritionGoals.carbs, color: AppColors.carbs)
                macroRow(label: "Fat", value: fat, goal: NutritionGoals.fat, color: AppColors.fat)
            }
        }
        .padding(AppSpacing.md)
        .background(AppColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg))
    }

    private func macroRow(label: String, value: Double, goal: Double, color: Color) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            HStack {
                Text(label)
                    .font(AppTypography.caption1.bold())
                Spacer()
                Text("\(Int(value))g")
                    .font(AppTypography.caption1)
                    .foregroundStyle(AppColors.textSecondary)
            }
            ProgressView(value: min(goal > 0 ? value / goal : 0, 1.0))
                .progressViewStyle(.linear)
                .tint(color)
                .animation(.easeInOut(duration: 0.3), value: min(goal > 0 ? value / goal : 0, 1.0))
        }
        .frame(minWidth: 100)
    }
}

#Preview {
    NutritionMacroHeader(
        calories: 450,
        protein: 30,
        carbs: 45,
        fat: 15
    )
    .padding()
}
