import SwiftUI

public struct Chip: View {
    let title: String
    let isSelected: Bool
    
    public init(_ title: String, isSelected: Bool = false) {
        self.title = title
        self.isSelected = isSelected
    }
    
    public var body: some View {
        Text(title)
            .font(AppTheme.typography.footnote)
            .padding(.vertical, AppTheme.spacing.sm)
            .padding(.horizontal, AppTheme.spacing.md)
            .background(isSelected ? AppTheme.colors.primary : AppTheme.colors.separator.opacity(0.1))
            .foregroundColor(isSelected ? .white : AppTheme.colors.textPrimary)
            .cornerRadius(AppRadius.full)
    }
}
