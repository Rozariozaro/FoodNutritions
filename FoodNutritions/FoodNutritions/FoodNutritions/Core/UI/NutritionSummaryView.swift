import SwiftUI

struct NutritionSummaryView: View {
    let calories: Double
    let protein: Double
    let carbs: Double
    let fat: Double

    var body: some View {
        VStack(spacing: AppSpacing.smMd) {
            HStack {
                VStack(alignment: .leading) {
                    Text(calories, format: .number.precision(.fractionLength(0)))
                        .font(AppTypography.title1.bold())
                        .contentTransition(.numericText())
                        .animation(.default, value: calories)
                    Text("Total Calories")
                        .font(AppTypography.caption1)
                        .foregroundStyle(AppColors.textSecondary)
                }

                Spacer()

                CalorieRingView(
                    current: calories,
                    goal: NutritionGoals.calories,
                    size: 60
                )
            }

            VStack(spacing: AppSpacing.sm) {
                MacroProgressBar(
                    label: "Protein",
                    current: protein,
                    goal: NutritionGoals.protein,
                    color: AppColors.protein
                )
                MacroProgressBar(
                    label: "Carbs",
                    current: carbs,
                    goal: NutritionGoals.carbs,
                    color: AppColors.carbs
                )
                MacroProgressBar(
                    label: "Fat",
                    current: fat,
                    goal: NutritionGoals.fat,
                    color: AppColors.fat
                )
            }
        }
        .padding(.vertical, AppSpacing.sm)
    }
}

#Preview {
    Form {
        Section {
            NutritionSummaryView(
                calories: 1200,
                protein: 80,
                carbs: 150,
                fat: 40
            )
        }
    }
}
