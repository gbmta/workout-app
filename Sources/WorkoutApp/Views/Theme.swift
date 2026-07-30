import SwiftUI
import UIKit

/// Design tokens for the whole app. Dark is the primary design target; light
/// values are derived. See docs/design-overhaul-plan.md — don't invent new
/// colors or spacing outside this file.
enum Theme {
    // MARK: - Colors

    static let bg = dynamicColor(dark: 0x0D0D0F, light: 0xF4F4F6)
    static let surface = dynamicColor(dark: 0x1A1A1E, light: 0xFFFFFF)
    /// Sits on top of `surface`, so its light value has to differ from `surface`'s white
    /// — otherwise raised elements (number fields, muscle chips) vanish in light mode.
    static let surfaceRaised = dynamicColor(dark: 0x232329, light: 0xEDEDF0)
    static let accent = dynamicColor(dark: 0xBFFF3C, light: 0x7BC618)
    static let onAccent = dynamicColor(dark: 0x0D0D0F, light: 0xFFFFFF)
    static let textPrimary = dynamicColor(dark: 0xF5F5F7, light: 0x111113)
    static let textSecondary = dynamicColor(dark: 0x9A9AA3, light: 0x6B6B74)
    static let warn = dynamicColor(dark: 0xFBBF24, light: 0xB45309)
    static let danger = dynamicColor(dark: 0xF87171, light: 0xDC2626)
    static let zoneUnder = dynamicColor(dark: 0x5A5A64, light: 0x9CA3AF)

    // MARK: - Exercise motion diagrams

    /// Tokens for the animated exercise-form diagrams. The design is a neutral
    /// grey figure + a single accent ramp (accent200 lightest → accent800
    /// darkest) used for the muscle glow, joint dots, and bar/plate. Per the
    /// handoff, the accent ramp is swapped to the app's volt-green. Dark values
    /// are the design intent; light values are darkened so the figure and glow
    /// stay legible on a white card.
    enum Diagram {
        static let body = Theme.dynamicColor(dark: 0x75798C, light: 0x84879A)      // body-mass strokes
        static let headFill = Theme.dynamicColor(dark: 0x3F424D, light: 0xE6E7EC)  // head / bench fill
        static let rail = Theme.dynamicColor(dark: 0x595D6C, light: 0xBABCC5)      // scaffolding rails

        static let accent200 = Theme.dynamicColor(dark: 0xEBFFC4, light: 0x4B7610) // glow core
        static let accent300 = Theme.dynamicColor(dark: 0xD6FF7A, light: 0x5C8F16) // dots, plate stroke, label
        static let accent400 = Theme.dynamicColor(dark: 0xBFFF3C, light: 0x86CF20) // glow halo
        static let accent500 = Theme.dynamicColor(dark: 0x9BE22B, light: 0x6BA31E) // leader lines
        static let accent600 = Theme.dynamicColor(dark: 0x7BC618, light: 0x7BC618) // plumb / bar-path dashes
        static let accent800 = Theme.dynamicColor(dark: 0x38501A, light: 0xDDF0B5) // plate / bar fill
    }

    // MARK: - Type

    static func numberFont(_ size: CGFloat) -> Font {
        .system(size: size, weight: .semibold, design: .rounded)
    }

    private static func dynamicColor(dark: UInt32, light: UInt32) -> Color {
        Color(UIColor { traits in
            traits.userInterfaceStyle == .dark ? UIColor(hex: dark) : UIColor(hex: light)
        })
    }
}

private extension UIColor {
    convenience init(hex: UInt32) {
        self.init(
            red: CGFloat((hex >> 16) & 0xFF) / 255,
            green: CGFloat((hex >> 8) & 0xFF) / 255,
            blue: CGFloat(hex & 0xFF) / 255,
            alpha: 1
        )
    }
}

// MARK: - Reusable styles

struct ThemeCard: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Theme.surface)
            .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

struct SectionLabel: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.caption.weight(.semibold))
            .textCase(.uppercase)
            .tracking(1.2)
            .foregroundStyle(Theme.textSecondary)
    }
}

extension View {
    func themeCard() -> some View {
        modifier(ThemeCard())
    }

    func sectionLabel() -> some View {
        modifier(SectionLabel())
    }
}
