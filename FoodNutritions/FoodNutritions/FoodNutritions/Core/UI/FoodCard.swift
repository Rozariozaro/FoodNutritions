import SwiftUI

struct FoodCard: View {
    let food: FoodItem

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            HStack {
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text(food.name)
                        .font(AppTypography.headline)
                        .lineLimit(2)
                    Text(food.type.rawValue.capitalized)
                        .font(AppTypography.caption1)
                        .foregroundStyle(AppColors.textSecondary)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: AppSpacing.xs) {
                    Text(String(format: "%.0f kcal", food.caloriesPer100g))
                        .font(AppTypography.subhead.bold())
                    Text("per 100g")
                        .font(AppTypography.caption1)
                        .foregroundStyle(AppColors.textSecondary)
                }
            }

            HStack(spacing: AppSpacing.md) {
                MacroChip(label: "P", value: food.proteinPer100g, color: AppColors.protein)
                MacroChip(label: "C", value: food.carbsPer100g, color: AppColors.carbs)
                MacroChip(label: "F", value: food.fatPer100g, color: AppColors.fat)
            }
        }
        .padding(AppSpacing.smMd)
        .background(AppColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
        .appShadowSoft()
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(food.name), \(Int(food.caloriesPer100g)) kilocalories per 100 grams, protein \(Int(food.proteinPer100g)) grams, carbs \(Int(food.carbsPer100g)) grams, fat \(Int(food.fatPer100g)) grams")
    }
}

private struct MacroChip: View {
    let label: String
    let value: Double
    let color: Color

    var body: some View {
        HStack(spacing: AppSpacing.xs) {
            Text(label)
                .font(AppTypography.caption1.bold())
                .foregroundStyle(color)
            Text(String(format: "%.1fg", value))
                .font(AppTypography.caption1)
                .foregroundStyle(AppColors.textSecondary)
        }
    }
}
