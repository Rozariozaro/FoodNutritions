import SwiftUI

struct CalendarRibbon: View {
    let availableDates: [Date]
    @Binding var selectedDate: Date
    let onDateSelected: (Date) -> Void

    private let calendar = Calendar.current

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppSpacing.smMd) {
                    ForEach(availableDates, id: \.self) { date in
                        DateCell(
                            date: date,
                            isSelected: calendar.isDate(date, inSameDayAs: selectedDate)
                        ) {
                            onDateSelected(date)
                        }
                        .id(date)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, AppSpacing.sm)
            }
            .onAppear {
                proxy.scrollTo(selectedDate, anchor: .center)
            }
            .onChange(of: selectedDate) { _, newDate in
                withAnimation {
                    proxy.scrollTo(newDate, anchor: .center)
                }
            }
        }
        .background(AppColors.background)
    }
}

private struct DateCell: View {
    let date: Date
    let isSelected: Bool
    let action: () -> Void

    @ScaledMetric private var cellWidth: CGFloat = 50
    @ScaledMetric private var cellHeight: CGFloat = 60

    private var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }

    var body: some View {
        Button(action: action) {
            VStack(spacing: AppSpacing.xs) {
                Text(date.formatted(.dateTime.weekday(.abbreviated)))
                    .font(AppTypography.caption1.weight(.medium))
                    .foregroundStyle(isSelected ? .white : AppColors.textSecondary)

                Text(date.formatted(.dateTime.day()))
                    .font(AppTypography.headline)
                    .foregroundStyle(isSelected ? .white : AppColors.textPrimary)
            }
            .frame(width: cellWidth, height: cellHeight)
            .background {
                if isSelected {
                    RoundedRectangle(cornerRadius: AppRadius.md)
                        .fill(AppColors.primary.gradient)
                } else if isToday {
                     RoundedRectangle(cornerRadius: AppRadius.md)
                        .stroke(AppColors.primary, lineWidth: 1)
                } else {
                    RoundedRectangle(cornerRadius: AppRadius.md)
                        .fill(AppColors.surface)
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(date.formatted(date: .complete, time: .omitted))
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .accessibilityAddTraits(isToday ? .isHeader : [])
    }
}
