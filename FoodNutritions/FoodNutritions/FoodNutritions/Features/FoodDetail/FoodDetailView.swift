import SwiftUI

struct FoodDetailView: View {
    @Bindable var processor: FoodDetailProcessor
    var onItemAdded: (MealItem) -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: AppSpacing.lg) {
                // Header
                VStack(spacing: AppSpacing.sm) {
                    Text(processor.state.foodItem.name)
                        .font(AppTypography.largeTitle.bold())
                        .multilineTextAlignment(.center)

                    Text(processor.state.foodItem.type.rawValue.capitalized)
                        .font(AppTypography.headline)
                        .foregroundStyle(AppColors.textSecondary)
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
                        VStack(alignment: .leading, spacing: AppSpacing.xs) {
                            Text("Unit")
                                .font(AppTypography.caption1)
                                .foregroundStyle(AppColors.textSecondary)

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

                        VStack(alignment: .trailing, spacing: AppSpacing.xs) {
                            Text("Quantity")
                                .font(AppTypography.caption1)
                                .foregroundStyle(AppColors.textSecondary)
                            
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
                        ErrorBanner(message: error)
                    }
                }

                // Micronutrients Section
                FoodDetailSection {
                    HStack {
                        Text("Micronutrients")
                            .font(AppTypography.headline)
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
                                .font(AppTypography.subhead)
                                .italic()
                                .foregroundStyle(AppColors.textSecondary)
                        } else {
                            MicronutrientListView(micronutrients: processor.state.foodItem.micronutrients)
                        }
                    }
                }

                // Add to Meal Button
                Button(action: addToMeal) {
                    Text("Add to Meal")
                        .font(AppTypography.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(AppSpacing.md)
                        .background(processor.state.errorMessage == nil ? AppColors.primary : AppColors.textSecondary)
                        .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg))
                }
                .disabled(processor.state.errorMessage != nil)
                .padding(.top)
            }
            .padding()
        }
        .navigationTitle(processor.state.foodItem.name)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func addToMeal() {
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
    }
}
