import SwiftUI

// See also: Core/UI/CalorieRingView.swift (labelled calorie ring with goal text and over-goal state)
public struct CircularProgressView: View {
    let progress: Double // 0.0 to 1.0
    let primaryColor: Color
    
    public init(progress: Double, primaryColor: Color = AppColors.primary) {
        self.progress = progress
        self.primaryColor = primaryColor
    }
    
    public var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 8)
                .opacity(0.1)
                .foregroundColor(AppTheme.colors.separator)
            
            Circle()
                .trim(from: 0.0, to: CGFloat(min(progress, 1.0)))
                .stroke(style: StrokeStyle(lineWidth: 8, lineCap: .round, lineJoin: .round))
                .foregroundColor(primaryColor)
                .rotationEffect(Angle(degrees: 270.0))
        }
    }
}
