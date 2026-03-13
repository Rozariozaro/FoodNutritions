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
            VStack(alignment: .leading) {
                Text(foodName)
                    .font(.headline)
                Text("\(Int(servingGrams))g")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text("\(Int(calories)) kcal")
                    .font(.subheadline)
                    .bold()
                Text("P: \(Int(protein))g • C: \(Int(carbs))g • F: \(Int(fat))g")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
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
