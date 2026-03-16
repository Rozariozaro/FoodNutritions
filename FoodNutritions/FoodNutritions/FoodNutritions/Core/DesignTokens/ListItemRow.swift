import SwiftUI

// See also: Core/UI/MealItemRow.swift (food-specific row with macro detail)
public struct ListItemRow<Content: View>: View {
    let content: Content
    
    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    public var body: some View {
        HStack(spacing: AppTheme.spacing.md) {
            content
        }
        .padding(AppTheme.spacing.md)
        .background(AppTheme.colors.surface)
        .cornerRadius(AppTheme.radius.lg)
    }
}
