// See also: Core/DesignTokens/ListItemRow.swift (generic HStack layout wrapper)
import SwiftUI

struct MealItemRow: View {
    let foodName: String
    let servingGrams: Double
    let calories: Double
    let protein: Double
    let carbs: Double
    let fat: Double

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text(foodName)
                    .font(AppTypography.headline)
                Text("\(Int(servingGrams))g")
                    .font(AppTypography.subhead)
                    .foregroundStyle(AppColors.textSecondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: AppSpacing.xs) {
                Text("\(Int(calories)) kcal")
                    .font(AppTypography.subhead.bold())
                Text("P: \(Int(protein))g • C: \(Int(carbs))g • F: \(Int(fat))g")
                    .font(AppTypography.caption1)
                    .foregroundStyle(AppColors.textSecondary)
            }
        }
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(foodName), \(Int(servingGrams)) grams, \(Int(calories)) kilocalories")
    }
}

#Preview {
    List {
        MealItemRow(
            foodName: "Chicken Breast",
            servingGrams: 150,
            calories: 247,
            protein: 46,
            carbs: 0,
            fat: 5
        )
    }
}
