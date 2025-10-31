import SwiftUI

struct LiquidGlassBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    AppTheme.Colors.background.opacity(0.95),
                    AppTheme.Colors.background.opacity(0.85)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            RadialGradient(
                colors: [
                    AppTheme.Colors.primary.opacity(0.25),
                    .clear
                ],
                center: .topLeading,
                startRadius: 20,
                endRadius: 600
            )
            .blur(radius: 60)

            RadialGradient(
                colors: [
                    AppTheme.Colors.secondary.opacity(0.2),
                    .clear
                ],
                center: .bottomTrailing,
                startRadius: 20,
                endRadius: 500
            )
            .blur(radius: 50)
        }
    }
}

private struct LiquidGlassStroke: View {
    let cornerRadius: CGFloat
    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .strokeBorder(
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.35),
                        Color.white.opacity(0.05)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: 1
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.08),
                                Color.white.opacity(0.02)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .blendMode(.plusLighter)
                    .allowsHitTesting(false)
            )
    }
}

struct LiquidGlassCard: ViewModifier {
    let cornerRadius: CGFloat
    var borderTint: Color? = nil

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(
                        .thinMaterial
                    )
            )
            .overlay(
                ZStack {
                    LiquidGlassStroke(cornerRadius: cornerRadius)
                    if let borderTint = borderTint {
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .strokeBorder(
                                LinearGradient(
                                    colors: [
                                        borderTint.opacity(0.22),
                                        borderTint.opacity(0.06)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ), lineWidth: 0.8
                            )
                    }
                }
            )
            .shadow(color: Color.black.opacity(0.15), radius: 12, x: 0, y: 6)
            .shadow(color: AppTheme.Colors.primary.opacity(0.06), radius: 20, x: 0, y: 10)
    }
}

extension View {
    func liquidGlassCard(cornerRadius: CGFloat = AppTheme.CornerRadius.lg, borderTint: Color? = nil) -> some View {
        modifier(LiquidGlassCard(cornerRadius: cornerRadius, borderTint: borderTint))
    }
}


