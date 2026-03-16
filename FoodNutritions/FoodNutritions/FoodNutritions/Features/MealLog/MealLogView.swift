import SwiftUI

struct MealLogView: View {
    @Bindable var processor: MealLogProcessor
    @Environment(\.dismiss) private var dismiss
    // FUNC-01: callback to push Search so user can add more food
    var onAddFoodRequested: (() -> Void)?

    var body: some View {
        List {
            Section("Meal Items") {
                if processor.state.items.isEmpty {
                    // UI-08: empty-state with explanation when save is blocked
                    ContentUnavailableView(
                        "No Items Added",
                        systemImage: "fork.knife",
                        description: Text("Tap \"Add Food\" to search for items to include in this meal.")
                    )
                    .listRowSeparator(.hidden)
                } else {
                    ForEach(processor.state.items) { item in
                        MealItemRow(
                            foodName: item.foodName,
                            servingGrams: item.servingGrams,
                            calories: item.calories,
                            protein: item.protein,
                            carbs: item.carbs,
                            fat: item.fat
                        )
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            processor.send(.removeItem(processor.state.items[index].id))
                        }
                    }
                }
            }

            Section("Meal Details") {
                Picker("Meal Type", selection: Binding(
                    get: { processor.state.selectedMealType },
                    set: { processor.send(.mealTypeChanged($0)) }
                )) {
                    ForEach(MealType.allCases, id: \.self) { type in
                        Text(type.rawValue.capitalized).tag(type)
                    }
                }
            }

            Section("Nutrition Summary") {
                NutritionSummaryView(
                    calories: processor.state.totals.calories,
                    protein: processor.state.totals.protein,
                    carbs: processor.state.totals.carbs,
                    fat: processor.state.totals.fat
                )
            }
        }
        .navigationTitle(processor.state.isEditMode ? "Edit Meal" : "Log Meal")
        .toolbar {
            // FUNC-01: Add Food button always visible so user can add items
            ToolbarItem(placement: .topBarLeading) {
                Button("Add Food") {
                    onAddFoodRequested?()
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button(processor.state.isEditMode ? "Update" : "Save") {
                    processor.send(.saveMeal)
                }
                .bold()
                .disabled(processor.state.items.isEmpty || processor.state.isSaving)
            }
        }
        .overlay {
            if processor.state.isSaving {
                ProgressView("Saving Meal...")
                    .padding(AppSpacing.md)
                    .background(AppColors.surfaceElevated)
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
            }
        }
        .alert("Error", isPresented: Binding(
            get: { processor.state.errorMessage != nil },
            set: { _ in processor.send(.dismissError) }
        )) {
            Button("OK", role: .cancel) { }
        } message: {
            if let error = processor.state.errorMessage {
                Text(error)
            }
        }
        .onChange(of: processor.state.shouldNavigateBack) { _, shouldPop in
            if shouldPop {
                processor.send(.resetNavigation)
                dismiss()
            }
        }
    }
}

#Preview {
    NavigationStack {
        Text("MealLogView Preview")
    }
}
