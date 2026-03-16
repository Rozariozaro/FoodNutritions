import SwiftUI

public enum AppShadows {
    public static func cardSoft<S: Shape>(_ content: S) -> some View {
        content.shadow(color: Color.black.opacity(0.05), radius: 12, x: 0, y: 4)
    }
}

public extension View {
    func appShadowSoft() -> some View {
        self.shadow(color: Color.black.opacity(0.05), radius: 12, x: 0, y: 4)
    }
}
