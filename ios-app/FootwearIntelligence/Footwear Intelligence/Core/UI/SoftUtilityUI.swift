import SwiftUI

struct SoftPanelModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

struct ElevatedPanelModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                LinearGradient(
                    colors: [Color(.secondarySystemGroupedBackground), Color(.tertiarySystemGroupedBackground)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(Color.white.opacity(0.35), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .shadow(color: Color.black.opacity(0.06), radius: 16, x: 0, y: 8)
    }
}

struct PremiumHeroModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(24)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                LinearGradient(
                    colors: [Color(red: 0.12, green: 0.16, blue: 0.15), Color(red: 0.26, green: 0.31, blue: 0.27)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.08))
                        .frame(width: 180, height: 180)
                        .offset(x: 120, y: -80)
                    Circle()
                        .fill(Color.white.opacity(0.05))
                        .frame(width: 120, height: 120)
                        .offset(x: 70, y: 100)
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .stroke(Color.white.opacity(0.10), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
            .shadow(color: Color.black.opacity(0.14), radius: 24, x: 0, y: 14)
    }
}

struct MetricTileModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white.opacity(0.72))
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .shadow(color: Color.black.opacity(0.04), radius: 12, x: 0, y: 6)
    }
}

extension View {
    func softPanelStyle() -> some View {
        modifier(SoftPanelModifier())
    }

    func elevatedPanelStyle() -> some View {
        modifier(ElevatedPanelModifier())
    }

    func premiumHeroStyle() -> some View {
        modifier(PremiumHeroModifier())
    }

    func metricTileStyle() -> some View {
        modifier(MetricTileModifier())
    }
}

enum SoftUtilityRiskTone {
    static func color(for level: String) -> Color {
        switch level.lowercased() {
        case "high": return .red
        case "medium": return .orange
        default: return .green
        }
    }

    static func shortLabel(for level: String) -> String {
        switch level.lowercased() {
        case "high": return "Needs attention soon"
        case "medium": return "Worth keeping an eye on"
        default: return "Holding up well"
        }
    }

    static func longLabel(for level: String) -> String {
        switch level.lowercased() {
        case "high": return "This footwear may need replacing soon."
        case "medium": return "This footwear is worth keeping an eye on."
        default: return "This footwear looks to be holding up well."
        }
    }

    static func fill(for level: String) -> Color {
        switch level.lowercased() {
        case "high": return Color.red.opacity(0.14)
        case "medium": return Color.orange.opacity(0.16)
        default: return Color.green.opacity(0.14)
        }
    }
}
