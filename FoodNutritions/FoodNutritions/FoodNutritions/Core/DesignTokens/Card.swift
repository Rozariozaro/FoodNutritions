import SwiftUI

public struct Card<Content: View>: View {
    let content: Content
    let isHighlighted: Bool
    
    public init(isHighlighted: Bool = false, @ViewBuilder content: () -> Content) {
        self.isHighlighted = isHighlighted
        self.content = content()
    }
    
    public var body: some View {
        content
            .padding(AppTheme.spacing.md)
            .background(isHighlighted ? AppTheme.colors.primary.opacity(0.05) : AppTheme.colors.surface)
            .cornerRadius(AppTheme.radius.lg)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.radius.lg)
                    .stroke(isHighlighted ? AppTheme.colors.primary.opacity(0.1) : Color.clear, lineWidth: 1)
            )
            .appShadowSoft()
    }
}
