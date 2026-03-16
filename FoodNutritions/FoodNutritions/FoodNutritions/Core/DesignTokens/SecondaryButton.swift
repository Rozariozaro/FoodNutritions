import SwiftUI

public struct SecondaryButton: View {
    let title: String
    let action: () -> Void
    
    public init(_ title: String, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            Text(title)
                .font(AppTheme.typography.headline)
                .foregroundColor(AppTheme.colors.primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppTheme.spacing.md)
                .padding(.horizontal, AppTheme.spacing.lg)
                .background(AppTheme.colors.primary.opacity(0.1))
                .cornerRadius(AppTheme.radius.md)
        }
    }
}
