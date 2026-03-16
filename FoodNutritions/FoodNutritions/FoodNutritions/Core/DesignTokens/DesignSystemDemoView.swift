import SwiftUI

struct DesignSystemDemoView: View {
    @State private var progress = 0.65
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppTheme.spacing.xl) {
                // Typography & Colors
                VStack(alignment: .leading, spacing: AppTheme.spacing.sm) {
                    Text("Typography & Colors")
                        .font(AppTheme.typography.title1)
                        .foregroundColor(AppTheme.colors.textPrimary)
                    
                    Text("This is Large Title")
                        .font(AppTheme.typography.largeTitle)
                    Text("This is Title 1")
                        .font(AppTheme.typography.title1)
                    Text("This is Headline")
                        .font(AppTheme.typography.headline)
                    Text("This is Body text with secondary color")
                        .font(AppTheme.typography.body)
                        .foregroundColor(AppTheme.colors.textSecondary)
                }
                
                // Buttons
                VStack(alignment: .leading, spacing: AppTheme.spacing.md) {
                    Text("Buttons")
                        .font(AppTheme.typography.title2)
                    
                    PrimaryButton("Primary Action") {
                        print("Primary tapped")
                    }
                    
                    SecondaryButton("Secondary Action") {
                        print("Secondary tapped")
                    }
                }
                
                // Cards & Chips
                VStack(alignment: .leading, spacing: AppTheme.spacing.md) {
                    Text("Cards & Chips")
                        .font(AppTheme.typography.title2)
                    
                    HStack {
                        Chip("Protein", isSelected: true)
                        Chip("Carbs")
                        Chip("Fat")
                    }
                    
                    Card {
                        VStack(alignment: .leading, spacing: AppTheme.spacing.sm) {
                            Text("Standard Card")
                                .font(AppTheme.typography.headline)
                            Text("This is a standard elevated card using design tokens.")
                                .font(AppTheme.typography.subhead)
                        }
                    }
                    
                    Card(isHighlighted: true) {
                        VStack(alignment: .leading, spacing: AppTheme.spacing.sm) {
                            Text("Highlighted Card")
                                .font(AppTheme.typography.headline)
                                .foregroundColor(AppTheme.colors.primary)
                            Text("This card uses the primary brand tint.")
                                .font(AppTheme.typography.subhead)
                        }
                    }
                }
                
                // Progress
                VStack(alignment: .leading, spacing: AppTheme.spacing.md) {
                    Text("Progress Indicators")
                        .font(AppTheme.typography.title2)
                    
                    HStack(spacing: AppTheme.spacing.lg) {
                        CircularProgressView(progress: progress)
                            .frame(width: 80, height: 80)
                        
                        VStack(spacing: AppTheme.spacing.md) {
                            MacroProgressToken(value: 0.8, color: AppTheme.colors.protein, label: "Protein")
                            MacroProgressToken(value: 0.4, color: AppTheme.colors.carbs, label: "Carbs")
                            MacroProgressToken(value: 0.6, color: AppTheme.colors.fat, label: "Fat")
                        }
                    }
                }

            }
            .padding(AppTheme.spacing.md)
        }
        .background(AppTheme.colors.background)
    }
}

#Preview {
    DesignSystemDemoView()
}
