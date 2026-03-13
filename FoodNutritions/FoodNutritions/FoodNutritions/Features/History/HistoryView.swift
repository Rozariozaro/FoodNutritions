import SwiftUI

struct HistoryView: View {
    @State var processor: HistoryProcessor
    var onMealSelected: (MealRecord) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            if !processor.state.availableDates.isEmpty {
                CalendarRibbon(
                    availableDates: processor.state.availableDates,
                    selectedDate: $processor.state.selectedDate,
                    onDateSelected: { processor.send(.selectDate($0)) }
                )
                Divider()
            }
            
            if processor.state.isLoading && processor.state.meals.isEmpty {
                VStack {
                    Spacer()
                    ProgressView("Loading History...")
                    Spacer()
                }
            } else {
                mealList
            }
        }
        .navigationTitle("History")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            processor.send(.loadDates)
        }
        .alert("Error", isPresented: .init(
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
    
    @ViewBuilder
    private var mealList: some View {
        if processor.state.meals.isEmpty {
            ContentUnavailableView(
                "No Meals Logged",
                systemImage: "calendar.badge.exclamationmark",
                description: Text("No nutrition data found for this date.")
            )
        } else {
            List {
                Section {
                    NutritionSummaryView(
                        calories: processor.state.meals.reduce(0) { $0 + DailySummary.from(items: $1.items).calories },
                        protein: processor.state.meals.reduce(0) { $0 + DailySummary.from(items: $1.items).protein },
                        carbs: processor.state.meals.reduce(0) { $0 + DailySummary.from(items: $1.items).carbs },
                        fat: processor.state.meals.reduce(0) { $0 + DailySummary.from(items: $1.items).fat }
                    )
                }
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))

                Section("Meals") {
                    ForEach(processor.state.meals) { meal in
                        Button {
                            onMealSelected(meal)
                        } label: {
                            let summary = DailySummary.from(items: meal.items)
                            MealItemRow(
                                foodName: meal.mealType.capitalized,
                                servingGrams: meal.items.reduce(0) { $0 + $1.servingGrams },
                                calories: summary.calories,
                                protein: summary.protein,
                                carbs: summary.carbs,
                                fat: summary.fat
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .listStyle(.insetGrouped)
        }
    }
}
