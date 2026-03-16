import SwiftUI

struct DashboardView: View {
    @Bindable var processor: DashboardProcessor
    var onSearchRequested: () -> Void
    var onMealSelected: (MealRecord) -> Void

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(spacing: 0) {
                // UI-01: offline banner pinned above the List (not inside it)
                if !processor.networkMonitor.isConnected {
                    ErrorBanner(message: "You're offline. Some data may be outdated.")
                        .padding(.horizontal)
                        .padding(.vertical, AppSpacing.sm)
                }

                List {
                    // Nutritional Summary Header
                    Section {
                        NutritionSummaryView(
                            calories: processor.state.summary.calories,
                            protein: processor.state.summary.protein,
                            carbs: processor.state.summary.carbs,
                            fat: processor.state.summary.fat
                        )
                    }
                    .listRowInsets(EdgeInsets(top: AppSpacing.md, leading: AppSpacing.md, bottom: AppSpacing.md, trailing: AppSpacing.md))
                    .background(AppColors.background)

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
                // UI-03: reserve space so the last row isn't hidden behind the FAB
                .safeAreaInset(edge: .bottom) {
                    Color.clear.frame(height: AppSpacing.xxl + AppSpacing.xl)
                }
                .refreshable {
                    processor.send(.loadData)
                }
            }
            .navigationTitle("Dashboard")

            // Floating Action Button (FAB)
            Button(action: onSearchRequested) {
                Image(systemName: "plus")
                    .font(AppTypography.title2.bold())
                    .foregroundStyle(.white)
                    .padding()
                    .background(
                        Circle()
                            .fill(AppColors.primary)
                            .appShadowSoft()
                    )
            }
            .padding(AppSpacing.lg)
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
        Text("Dashboard Preview")
    }
}
