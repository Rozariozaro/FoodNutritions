import SwiftUI

struct NutritionMacroHeader: View {
    let calories: Double
    let protein: Double
    let carbs: Double
    let fat: Double
    
    var body: some View {
        HStack(spacing: 32) {
            CalorieRingView(
                current: calories,
                goal: NutritionGoals.calories,
                ringColor: .orange,
                size: 140
            )

            VStack(alignment: .leading, spacing: 12) {
                macroRow(label: "Protein", value: protein, goal: NutritionGoals.protein, color: .blue)
                macroRow(label: "Carbs", value: carbs, goal: NutritionGoals.carbs, color: .green)
                macroRow(label: "Fat", value: fat, goal: NutritionGoals.fat, color: .orange)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    private func macroRow(label: String, value: Double, goal: Double, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(label)
                    .font(.caption.bold())
                Spacer()
                Text("\(Int(value))g")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            ProgressView(value: min(goal > 0 ? value / goal : 0, 1.0))
                .progressViewStyle(.linear)
                .tint(color)
        }
        .frame(width: 120)
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
