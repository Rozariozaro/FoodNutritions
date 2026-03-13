import SwiftUI

struct FoodCard: View {
    let food: FoodItem

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(food.name)
                        .font(.headline)
                        .lineLimit(2)
                    Text(food.type.rawValue.capitalized)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text(String(format: "%.0f kcal", food.caloriesPer100g))
                        .font(.subheadline.bold())
                    Text("per 100g")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            HStack(spacing: 16) {
                MacroChip(label: "P", value: food.proteinPer100g, color: .blue)
                MacroChip(label: "C", value: food.carbsPer100g, color: .green)
                MacroChip(label: "F", value: food.fatPer100g, color: .orange)
            }
        }
        .padding(12)
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 2)
    }
}

private struct MacroChip: View {
    let label: String
    let value: Double
    let color: Color

    var body: some View {
        HStack(spacing: 2) {
            Text(label)
                .font(.caption2.bold())
                .foregroundStyle(color)
            Text(String(format: "%.1fg", value))
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
}
