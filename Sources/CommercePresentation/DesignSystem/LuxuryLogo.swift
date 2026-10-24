#if os(iOS)
import SwiftUI

/// LuxuryMonogram represents the architectural "C" monogram of Commerce
/// designed according to the Monolith Noir aesthetic.
public struct LuxuryMonogram: Shape {
    public init() {}

    public func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height
        var path = Path()

        // Outer curve & terminals of the Monogram "C"
        let outerStartX = w * 0.72
        let outerStartY = h * 0.32
        path.move(to: CGPoint(x: outerStartX, y: outerStartY))

        // Top arc
        path.addCurve(
            to: CGPoint(x: w * 0.50, y: h * 0.22),
            control1: CGPoint(x: w * 0.66, y: h * 0.24),
            control2: CGPoint(x: w * 0.59, y: h * 0.22)
        )
        // Left arc
        path.addCurve(
            to: CGPoint(x: w * 0.22, y: h * 0.50),
            control1: CGPoint(x: w * 0.34, y: h * 0.22),
            control2: CGPoint(x: w * 0.22, y: h * 0.34)
        )
        // Bottom arc
        path.addCurve(
            to: CGPoint(x: w * 0.50, y: h * 0.78),
            control1: CGPoint(x: w * 0.22, y: h * 0.66),
            control2: CGPoint(x: w * 0.34, y: h * 0.78)
        )
        // Bottom terminal
        path.addCurve(
            to: CGPoint(x: outerStartX, y: h * 0.68),
            control1: CGPoint(x: w * 0.59, y: h * 0.78),
            control2: CGPoint(x: w * 0.66, y: h * 0.76)
        )

        // Bottom horizontal cut
        path.addLine(to: CGPoint(x: w * 0.64, y: h * 0.62))

        // Inner curve
        path.addCurve(
            to: CGPoint(x: w * 0.50, y: h * 0.69),
            control1: CGPoint(x: w * 0.60, y: h * 0.67),
            control2: CGPoint(x: w * 0.56, y: h * 0.69)
        )
        path.addCurve(
            to: CGPoint(x: w * 0.33, y: h * 0.50),
            control1: CGPoint(x: w * 0.40, y: h * 0.69),
            control2: CGPoint(x: w * 0.33, y: h * 0.60)
        )
        path.addCurve(
            to: CGPoint(x: w * 0.50, y: h * 0.31),
            control1: CGPoint(x: w * 0.33, y: h * 0.40),
            control2: CGPoint(x: w * 0.40, y: h * 0.31)
        )
        path.addCurve(
            to: CGPoint(x: w * 0.64, y: h * 0.38),
            control1: CGPoint(x: w * 0.56, y: h * 0.31),
            control2: CGPoint(x: w * 0.60, y: h * 0.33)
        )

        // Close path back to top terminal
        path.closeSubpath()

        return path
    }
}

@MainActor
public struct LuxuryLogo: View {
    public enum Style {
        /// Monolith card with black background and crisp white monogram
        case monolith
        /// Minimalist standalone icon without outer background box
        case minimal
        /// Monolith mark paired with the full tracked brand typography
        case full
    }

    private let size: CGFloat
    private let style: Style

    public init(size: CGFloat = 64, style: Style = .monolith) {
        self.size = size
        self.style = style
    }

    public var body: some View {
        switch style {
        case .monolith:
            monolithBadge
        case .minimal:
            LuxuryMonogram()
                .fill(LuxuryTheme.ink)
                .frame(width: size, height: size)
                .accessibilityLabel("Logo Commerce")
        case .full:
            VStack(spacing: size * 0.18) {
                monolithBadge
                Text("COMMERCE")
                    .font(.system(size: max(10, size * 0.16), weight: .semibold))
                    .tracking(size * 0.08)
                    .foregroundStyle(LuxuryTheme.ink)
            }
        }
    }

    private var monolithBadge: some View {
        ZStack {
            Rectangle()
                .fill(Color.black)
                .overlay(
                    Rectangle()
                        .stroke(Color.white.opacity(0.18), lineWidth: 1)
                        .padding(size * 0.08)
                )

            LuxuryMonogram()
                .fill(Color.white)
                .padding(size * 0.18)
        }
        .frame(width: size, height: size)
        .overlay(Rectangle().stroke(LuxuryTheme.border, lineWidth: 1))
        .accessibilityLabel("Logo Commerce C")
    }
}

#endif

