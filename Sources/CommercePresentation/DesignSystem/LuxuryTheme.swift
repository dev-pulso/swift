#if os(iOS)
import SwiftUI
import UIKit

enum LuxuryTheme {
    // Light values from Stitch's Monolith Noir; dark values are a native adaptation.
    static let canvas = adaptive(light: 0xF9F9F9, dark: 0x111111)
    static let surface = adaptive(light: 0xFFFFFF, dark: 0x1B1B1B)
    static let ink = adaptive(light: 0x000000, dark: 0xFFFFFF)
    static let muted = adaptive(light: 0x666666, dark: 0xB8B8B8)
    static let border = adaptive(light: 0xE5E5E5, dark: 0x414141)
    static let danger = adaptive(light: 0xBA1A1A, dark: 0xFFB4AB)
    static let gutter: CGFloat = 20
    static let gap: CGFloat = 16
    static let sectionGap: CGFloat = 32

    private static func adaptive(light: UInt32, dark: UInt32) -> Color {
        Color(uiColor: UIColor { traits in
            let value = traits.userInterfaceStyle == .dark ? dark : light
            return UIColor(red: CGFloat((value >> 16) & 255) / 255,
                           green: CGFloat((value >> 8) & 255) / 255,
                           blue: CGFloat(value & 255) / 255, alpha: 1)
        })
    }
}

extension View {
    func luxuryCanvas() -> some View {
        self.background(LuxuryTheme.canvas).foregroundStyle(LuxuryTheme.ink)
    }
}

#endif
