import SwiftUI

public struct PrimaryButton: View {
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
                .foregroundColor(.white) // Surface color in Primary
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppTheme.spacing.md)
                .padding(.horizontal, AppTheme.spacing.lg)
                .background(AppTheme.colors.primary)
                .cornerRadius(AppTheme.radius.md)
        }
    }
}
