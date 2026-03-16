import SwiftUI

struct SearchView: View {
    @Bindable var processor: SearchProcessor
    @State private var showFilterSheet: Bool = false
    @FocusState private var searchFieldFocused: Bool

    let onFoodSelected: (FoodItem) -> Void

    var body: some View {
        VStack(spacing: 0) {
            searchBar
            if processor.state.isLoading {
                ProgressView()
                    .padding()
                Spacer()
            } else {
                mainContent
            }
        }
        .navigationTitle("Search Food")
        .navigationBarTitleDisplayMode(.large)
        .toolbar { toolbarContent }
        .sheet(isPresented: $showFilterSheet) { filterSheet }
        .onAppear { processor.send(.loadRecentSearches) }
    }

    // MARK: - Search Bar

    private var searchBar: some View {
        HStack(spacing: AppSpacing.sm) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                TextField("Search foods…", text: Binding(
                    get: { processor.state.query },
                    set: { processor.send(.queryChanged($0)) }
                ))
                .focused($searchFieldFocused)
                .autocorrectionDisabled()
                .submitLabel(.search)
                .onSubmit { processor.submitSearch() }
                if !processor.state.query.isEmpty {
                    Button { processor.send(.queryChanged("")) } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(AppSpacing.sm)
            .background(AppColors.surface)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))

            if searchFieldFocused {
                Button("Cancel") {
                    // UI-07: dismiss keyboard only, preserve query and results
                    searchFieldFocused = false
                }
                .transition(.move(edge: .trailing).combined(with: .opacity))
                .animation(.easeInOut(duration: 0.2), value: searchFieldFocused)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, AppSpacing.sm)
    }

    // MARK: - Main Content

    @ViewBuilder
    private var mainContent: some View {
        ZStack(alignment: .top) {
            ScrollView {
                LazyVStack(spacing: 0) {
                    if let error = processor.state.errorMessage {
                        ErrorBanner(message: error)
                    }
                    if processor.state.searchResults.isEmpty && processor.state.query.isEmpty {
                        recentSearchesSection
                    } else if processor.state.searchResults.isEmpty && !processor.state.query.isEmpty {
                        emptyState
                    } else {
                        resultsSection
                    }
                }
                .padding(.horizontal)
                .padding(.top, processor.state.autocompleteSuggestions.isEmpty ? 0 : 8)
            }

            if !processor.state.autocompleteSuggestions.isEmpty && searchFieldFocused {
                autocompleteOverlay
            }
        }
    }

    // MARK: - Autocomplete Overlay

    private var autocompleteOverlay: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(processor.state.autocompleteSuggestions) { suggestion in
                Button {
                    processor.send(.queryChanged(suggestion.name))
                    processor.submitSearch()
                    searchFieldFocused = false
                } label: {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(.secondary)
                            .font(AppTypography.caption1)
                        Text(suggestion.name)
                            .foregroundStyle(.primary)
                        Spacer()
                        Text(suggestion.type.capitalized)
                            .font(AppTypography.caption1)
                            .foregroundStyle(AppColors.textSecondary)
                    }
                    .padding(.horizontal, AppSpacing.md)
                    .padding(.vertical, AppSpacing.smMd)
                }
                Divider().padding(.leading, AppSpacing.md)
            }
        }
        .background(AppColors.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
        .appShadowSoft()
        .padding(.horizontal)
        .padding(.top, AppSpacing.xs)
        .transition(.opacity.combined(with: .move(edge: .top)))
        .animation(.easeInOut(duration: 0.15), value: processor.state.autocompleteSuggestions.count)
    }

    // MARK: - Recent Searches

    private var recentSearchesSection: some View {
        Group {
            if !processor.state.recentSearches.isEmpty {
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    Text("Recent Searches")
                        .font(AppTypography.subhead.bold())
                        .foregroundStyle(AppColors.textSecondary)
                        .padding(.top, AppSpacing.md)
                    ForEach(processor.state.recentSearches, id: \.self) { query in
                        Button {
                            processor.send(.queryChanged(query))
                            processor.submitSearch()
                        } label: {
                            HStack {
                                Image(systemName: "clock.arrow.circlepath")
                                    .foregroundStyle(.secondary)
                                Text(query)
                                    .foregroundStyle(.primary)
                                Spacer()
                            }
                            .padding(.vertical, AppSpacing.sm)
                        }
                        Divider()
                    }
                }
            } else {
                ContentUnavailableView(
                    "Search for Food",
                    systemImage: "fork.knife.circle",
                    description: Text("Type a food name to see nutrition info.")
                )
                .padding(.top, 60)
            }
        }
    }

    // MARK: - Results

    private var resultsSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.smMd) {
            HStack {
                Text("\(processor.state.searchResults.count) results")
                    .font(AppTypography.subhead)
                    .foregroundStyle(AppColors.textSecondary)
                Spacer()
                SortMenuView(
                    title: "Sort",
                    selectedOption: Binding(
                        get: { processor.state.sortOption },
                        set: { processor.send(.sortChanged($0)) }
                    ),
                    options: SearchState.SortOption.allCases,
                    onOptionSelected: { processor.send(.sortChanged($0)) }
                )
            }
            .padding(.top, AppSpacing.sm)

            ForEach(processor.state.searchResults) { food in
                Button { onFoodSelected(food) } label: {
                    FoodCard(food: food)
                }
                .buttonStyle(.plain)
            }
        }
    }


    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: AppSpacing.md) {
            ContentUnavailableView.search(text: processor.state.query)
            if processor.state.filters.proteinMin > 0 ||
               processor.state.filters.caloriesMax < 10_000 ||
               processor.state.filters.carbsMax < 1_000 {
                Button("Clear Filters") {
                    processor.send(.clearFilters)
                }
                .buttonStyle(.bordered)
            }
        }
        .padding(.top, AppSpacing.xl)
    }


    // MARK: - Filter Sheet

    private var filterSheet: some View {
        NavigationStack {
            FilterSheetView(filters: processor.state.filters) { updated in
                processor.send(.filterChanged(updated))
                if !processor.state.query.isEmpty {
                    processor.submitSearch()
                }
            }
        }
    }

    // MARK: - Toolbar

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                showFilterSheet = true
            } label: {
                Image(systemName: hasActiveFilters ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
            }
        }
    }

    private var hasActiveFilters: Bool {
        processor.state.filters.proteinMin > 0 ||
        processor.state.filters.caloriesMax < 10_000 ||
        // UI-05: slider max is 1_000, so "active" means below that ceiling
        processor.state.filters.carbsMax < 1_000
    }
}

// MARK: - Filter Sheet View

private struct FilterSheetView: View {
    @State private var filters: SearchFilters
    @Environment(\.dismiss) private var dismiss
    let onApply: (SearchFilters) -> Void

    init(filters: SearchFilters, onApply: @escaping (SearchFilters) -> Void) {
        self._filters = State(initialValue: filters)
        self.onApply = onApply
    }

    var body: some View {
        Form {
            Section("Protein") {
                HStack {
                    Text("Min Protein")
                    Spacer()
                    Text(String(format: "%.0fg", filters.proteinMin))
                        .foregroundStyle(.secondary)
                }
                Slider(value: $filters.proteinMin, in: 0...100, step: 1)
            }
            Section("Calories") {
                HStack {
                    Text("Max Calories")
                    Spacer()
                    Text(String(format: "%.0f kcal", filters.caloriesMax))
                        .foregroundStyle(.secondary)
                }
                Slider(value: $filters.caloriesMax, in: 0...10_000, step: 50)
            }
            Section("Carbs") {
                HStack {
                    Text("Max Carbs")
                    Spacer()
                    Text(String(format: "%.0fg", filters.carbsMax))
                        .foregroundStyle(.secondary)
                }
                Slider(value: $filters.carbsMax, in: 0...1_000, step: 5)
            }
            Section {
                Button("Reset Filters", role: .destructive) {
                    filters = SearchFilters()
                }
            }
        }
        .navigationTitle("Filters")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Cancel") { dismiss() }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button("Apply") {
                    onApply(filters)
                    dismiss()
                }
                .fontWeight(.semibold)
            }
        }
    }
}
