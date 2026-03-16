import SwiftUI
import UIKit

// MARK: - UIColor dynamic helper

private extension UIColor {
    /// Creates a color that switches between light and dark appearance values.
    static func dynamic(light: UIColor, dark: UIColor) -> UIColor {
        UIColor { $0.userInterfaceStyle == .dark ? dark : light }
    }

    /// Initialises from a 6-digit hex string, e.g. "#F8F9FA".
    convenience init(hex: String, alpha: CGFloat = 1) {
        let hex = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        let value = UInt64(hex, radix: 16) ?? 0
        let r = CGFloat((value >> 16) & 0xFF) / 255
        let g = CGFloat((value >> 8)  & 0xFF) / 255
        let b = CGFloat( value        & 0xFF) / 255
        self.init(red: r, green: g, blue: b, alpha: alpha)
    }
}

// MARK: - AppColors

/// Semantic color tokens sourced from Design_Tokens.json.
/// All tokens automatically switch between light and dark appearances.
public enum AppColors {

    // MARK: Backgrounds

    /// #F8F9FA (light) / #0A0A0A (dark)
    public static let background = Color(UIColor.dynamic(
        light: UIColor(hex: "#F8F9FA"),
        dark:  UIColor(hex: "#0A0A0A")
    ))

    /// #FFFFFF (light) / #1C1C1E (dark)
    public static let surface = Color(UIColor.dynamic(
        light: UIColor(hex: "#FFFFFF"),
        dark:  UIColor(hex: "#1C1C1E")
    ))

    /// #FFFFFF (light) / #2C2C2E (dark)
    public static let surfaceElevated = Color(UIColor.dynamic(
        light: UIColor(hex: "#FFFFFF"),
        dark:  UIColor(hex: "#2C2C2E")
    ))

    // MARK: Brand

    /// #007AFF (light) / #0A84FF (dark)
    public static let primary = Color(UIColor.dynamic(
        light: UIColor(hex: "#007AFF"),
        dark:  UIColor(hex: "#0A84FF")
    ))

    // MARK: Text

    /// #111827 (light) / #FFFFFF (dark)
    public static let textPrimary = Color(UIColor.dynamic(
        light: UIColor(hex: "#111827"),
        dark:  UIColor(hex: "#FFFFFF")
    ))

    /// #6B7280 (light) / #A1A1AA (dark)
    public static let textSecondary = Color(UIColor.dynamic(
        light: UIColor(hex: "#6B7280"),
        dark:  UIColor(hex: "#A1A1AA")
    ))

    // MARK: Nutrition Macros

    /// #3B82F6 (light) / #60A5FA (dark)
    public static let protein = Color(UIColor.dynamic(
        light: UIColor(hex: "#3B82F6"),
        dark:  UIColor(hex: "#60A5FA")
    ))

    /// #22C55E (light) / #4ADE80 (dark)
    public static let carbs = Color(UIColor.dynamic(
        light: UIColor(hex: "#22C55E"),
        dark:  UIColor(hex: "#4ADE80")
    ))

    /// #F59E0B (light) / #FBBF24 (dark)
    public static let fat = Color(UIColor.dynamic(
        light: UIColor(hex: "#F59E0B"),
        dark:  UIColor(hex: "#FBBF24")
    ))

    // MARK: Semantic

    /// #EF4444 (light) / #F87171 (dark)
    public static let error = Color(UIColor.dynamic(
        light: UIColor(hex: "#EF4444"),
        dark:  UIColor(hex: "#F87171")
    ))

    /// #E5E7EB (light) / #38383A (dark)
    public static let separator = Color(UIColor.dynamic(
        light: UIColor(hex: "#E5E7EB"),
        dark:  UIColor(hex: "#38383A")
    ))

    /// rgba(0,122,255,0.1) (light) / rgba(10,132,255,0.15) (dark)
    public static let accentLowContrast = Color(UIColor.dynamic(
        light: UIColor(hex: "#007AFF", alpha: 0.10),
        dark:  UIColor(hex: "#0A84FF", alpha: 0.15)
    ))
}
