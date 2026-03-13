import SwiftUI

struct NutritionSummaryView: View {
    let calories: Double
    let protein: Double
    let carbs: Double
    let fat: Double
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading) {
                    Text("\(Int(calories))")
                        .font(.title.bold())
                    Text("Total Calories")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                CalorieRingView(
                    current: calories,
                    goal: NutritionGoals.calories,
                    size: 60
                )
            }
            
            VStack(spacing: 8) {
                MacroProgressBar(
                    label: "Protein",
                    current: protein,
                    goal: NutritionGoals.protein,
                    color: .blue
                )
                MacroProgressBar(
                    label: "Carbs",
                    current: carbs,
                    goal: NutritionGoals.carbs,
                    color: .green
                )
                MacroProgressBar(
                    label: "Fat",
                    current: fat,
                    goal: NutritionGoals.fat,
                    color: .orange
                )
            }
        }
        .padding(.vertical, 8)
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
