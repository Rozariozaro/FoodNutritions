import SwiftUI

struct DashboardView: View {
    @State var processor: DashboardProcessor
    var onSearchRequested: () -> Void
    var onMealSelected: (MealRecord) -> Void
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            List {
                if !processor.networkMonitor.isConnected {
                    Section {
                        HStack {
                            Image(systemName: "wifi.exclamationmark")
                            Text("You're offline. Some data may be outdated.")
                                .font(.subheadline)
                        }
                        .foregroundStyle(.white)
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity)
                        .listRowBackground(Color.orange)
                    }
                }
                
                // Nutritional Summary Header
                Section {
                    NutritionSummaryView(
                        calories: processor.state.summary.calories,
                        protein: processor.state.summary.protein,
                        carbs: processor.state.summary.carbs,
                        fat: processor.state.summary.fat
                    )
                }
                .listRowInsets(EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16))
                .background(Color(.systemBackground))
                
                // Today's Meals
                Section("Today's Meals") {
                    if processor.state.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .listRowSeparator(.hidden)
                    } else if processor.state.todayMeals.isEmpty {
                        ContentUnavailableView(
                            "No Meals Logged",
                            systemImage: "fork.knife",
                            description: Text("Start tracking by adding your first meal.")
                        )
                        .listRowSeparator(.hidden)
                    } else {
                        ForEach(processor.state.todayMeals) { meal in
                            Button {
                                onMealSelected(meal)
                            } label: {
                                let mealSummary = DailySummary.from(items: meal.items)
                                MealItemRow(
                                    foodName: meal.mealType.capitalized,
                                    servingGrams: meal.items.reduce(0) { $0 + $1.servingGrams },
                                    calories: mealSummary.calories,
                                    protein: mealSummary.protein,
                                    carbs: mealSummary.carbs,
                                    fat: mealSummary.fat
                                )
                            }
                            .buttonStyle(.plain)
                        }
                        .onDelete { indexSet in
                            for index in indexSet {
                                processor.send(.deleteMeal(processor.state.todayMeals[index].id))
                            }
                        }
                    }
                }
            }
            .navigationTitle("Dashboard")
            .refreshable {
                processor.send(.loadData)
            }

            // Floating Action Button (FAB)
            Button(action: onSearchRequested) {
                Image(systemName: "plus")
                    .font(.title2.bold())
                    .foregroundStyle(.white)
                    .padding()
                    .background(
                        Circle()
                            .fill(Color.blue)
                            .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
                    )
            }
            .padding(24)
        }
        .onAppear {
            processor.send(.loadData)
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
    }
}

#Preview {
    NavigationStack {
        // Mocked preview
        Text("Dashboard Preview")
    }
}
