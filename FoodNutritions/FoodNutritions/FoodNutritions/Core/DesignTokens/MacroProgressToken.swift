import SwiftUI

// See also: Core/UI/MacroProgressBar.swift (richer current/goal progress API for dashboard/summary use)
public struct MacroProgressToken: View {
    let value: Double // 0.0 to 1.0
    let color: Color
    let label: String
    
    public init(value: Double, color: Color, label: String) {
        self.value = value
        self.color = color
        self.label = label
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacing.xs) {
            Text(label)
                .font(AppTheme.typography.caption1)
                .foregroundColor(AppTheme.colors.textSecondary)
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: AppTheme.radius.sm)
                        .fill(AppTheme.colors.separator.opacity(0.1))
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: AppTheme.radius.sm)
                        .fill(color)
                        .frame(width: geometry.size.width * CGFloat(min(max(value, 0), 1)), height: 8)
                }
            }
            .frame(height: 8)
        }
    }
}
