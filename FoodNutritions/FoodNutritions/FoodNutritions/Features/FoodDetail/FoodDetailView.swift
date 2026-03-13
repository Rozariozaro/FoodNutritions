import SwiftUI

struct FoodDetailView: View {
    @State var processor: FoodDetailProcessor
    var onItemAdded: (MealItem) -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Text(processor.state.foodItem.name)
                        .font(.largeTitle.bold())
                        .multilineTextAlignment(.center)
                    
                    Text(processor.state.foodItem.type.rawValue.capitalized)
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }
                .padding(.top)

                // Macro Chart Section
                NutritionMacroHeader(
                    calories: processor.state.nutritionContext.calories,
                    protein: processor.state.nutritionContext.protein,
                    carbs: processor.state.nutritionContext.carbs,
                    fat: processor.state.nutritionContext.fat
                )

                // Servings & Quantity Section
                FoodDetailSection(title: "Adjust Serving") {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Unit")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            
                            Picker("Serving Unit", selection: Binding(
                                get: { processor.state.selectedServingUnit },
                                set: { processor.send(.servingUnitChanged($0)) }
                            )) {
                                ForEach(processor.state.foodItem.servingUnits) { unit in
                                    Text(unit.name).tag(unit)
                                }
                            }
                            .pickerStyle(.menu)
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: 4) {
                            Text("Quantity")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            
                            TextField("Quantity", value: Binding(
                                get: { processor.state.quantity },
                                set: { processor.send(.quantityChanged($0)) }
                            ), format: .number)
                            .textFieldStyle(.roundedBorder)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                        }
                    }
                    
                    if let error = processor.state.errorMessage {
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                }

                // Micronutrients Section
                FoodDetailSection {
                    HStack {
                        Text("Micronutrients")
                            .font(.headline)
                        Spacer()
                        Button(processor.state.isMicronutrientsVisible ? "Hide" : "Show") {
                            processor.send(.toggleMicronutrients)
                        }
                    }

                    if processor.state.isMicronutrientsVisible {
                        if processor.state.isLoadingMicros {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                                .padding()
                        } else if processor.state.foodItem.micronutrients.isEmpty {
                            Text("Detailed nutrition not available")
                                .font(.subheadline)
                                .italic()
                                .foregroundStyle(.secondary)
                        } else {
                            MicronutrientListView(micronutrients: processor.state.foodItem.micronutrients)
                        }
                    }
                }

                // Add to Meal Button
                Button {
                    let ctx = processor.state.nutritionContext
                    let grams = processor.state.effectiveGrams
                    let item = MealItem(
                        apiItemId: processor.state.foodItem.id,
                        apiItemType: processor.state.foodItem.type.rawValue,
                        foodName: processor.state.foodItem.name,
                        servingGrams: grams,
                        calories: ctx.calories,
                        protein: ctx.protein,
                        carbs: ctx.carbs,
                        fat: ctx.fat,
                        fiber: ctx.micronutrients.first { $0.name == "Fiber" }?.value,
                        sodiumMg: ctx.micronutrients.first { $0.name == "Sodium" }?.value
                    )
                    onItemAdded(item)
                } label: {
                    Text("Add to Meal")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(processor.state.errorMessage == nil ? Color.blue : Color.gray)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                }
                .disabled(processor.state.errorMessage != nil)
                .padding(.top)
            }
            .padding()
        }
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}
