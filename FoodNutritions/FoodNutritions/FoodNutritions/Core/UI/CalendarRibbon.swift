import SwiftUI

struct CalendarRibbon: View {
    let availableDates: [Date]
    @Binding var selectedDate: Date
    let onDateSelected: (Date) -> Void
    
    private let calendar = Calendar.current
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
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
                .padding(.vertical, 8)
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
        .background(Color(.systemBackground))
    }
}

private struct DateCell: View {
    let date: Date
    let isSelected: Bool
    let action: () -> Void
    
    private var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(date.formatted(.dateTime.weekday(.abbreviated)))
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundStyle(isSelected ? .white : .secondary)
                
                Text(date.formatted(.dateTime.day()))
                    .font(.headline)
                    .foregroundStyle(isSelected ? .white : .primary)
            }
            .frame(width: 50, height: 60)
            .background {
                if isSelected {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.blue.gradient)
                } else if isToday {
                     RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.blue, lineWidth: 1)
                } else {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.secondarySystemBackground))
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(date.formatted(date: .complete, time: .omitted))
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .accessibilityAddTraits(isToday ? .isHeader : [])
    }
}
