import SwiftUI

struct SortMenuView<Option: Identifiable & RawRepresentable>: View where Option.RawValue == String {
    let title: String
    @Binding var selectedOption: Option
    let options: [Option]
    let onOptionSelected: (Option) -> Void

    var body: some View {
        Menu {
            ForEach(options) { option in
                Button {
                    onOptionSelected(option)
                } label: {
                    if selectedOption.id == option.id {
                        Label(option.rawValue, systemImage: "checkmark")
                    } else {
                        Text(option.rawValue)
                    }
                }
            }
        } label: {
            Label("\(title): \(selectedOption.rawValue)", systemImage: "arrow.up.arrow.down")
                .font(AppTypography.subhead)
                .fontWeight(.medium)
                .padding(.vertical, AppSpacing.xs)
                .padding(.horizontal, AppSpacing.sm)
                .background(AppColors.surface)
                .clipShape(Capsule())
        }
    }
}
