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

struct SoftUtilityBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                LinearGradient(
                    colors: [Color(.systemGroupedBackground), Color(.secondarySystemGroupedBackground)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
    }
}

struct WarmAppBackground: ViewModifier {
    let top: Color
    let middle: Color

    init(top: Color = Color(red: 0.94, green: 0.93, blue: 0.89), middle: Color = Color(red: 0.90, green: 0.91, blue: 0.87)) {
        self.top = top
        self.middle = middle
    }

    func body(content: Content) -> some View {
        content
            .background(
                LinearGradient(
                    colors: [top, middle, Color(.systemGroupedBackground)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
    }
}

struct WarmHeroCard<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 36, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.18, green: 0.18, blue: 0.17),
                            Color(red: 0.26, green: 0.28, blue: 0.24),
                            Color(red: 0.39, green: 0.39, blue: 0.31)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(alignment: .topTrailing) {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.10))
                            .frame(width: 220, height: 220)
                            .offset(x: 80, y: -90)
                        Circle()
                            .fill(Color(red: 0.85, green: 0.89, blue: 0.78).opacity(0.14))
                            .frame(width: 150, height: 150)
                            .offset(x: 10, y: 65)
                    }
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 36, style: .continuous)
                        .stroke(Color.white.opacity(0.10), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.16), radius: 24, x: 0, y: 16)

            VStack(alignment: .leading, spacing: 18) {
                content
            }
            .padding(28)
        }
    }
}

struct WarmHeroStat: View {
    let value: String
    let label: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(value)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            Text(label)
                .font(.caption)
                .foregroundColor(Color.white.opacity(0.68))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color.white.opacity(0.10))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

struct WarmSectionHeader: View {
    let title: String
    let detail: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.title3)
                .bold()
            Text(detail)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}

struct WarmMetricTile: View {
    let label: String
    let value: String
    let caption: String
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Text(value)
                .font(.system(size: 28, weight: .bold, design: .rounded))
            Text(caption)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(tint.opacity(0.92))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 8)
    }
}

struct WarmSurfaceCard<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            content
        }
        .padding(22)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                colors: [Color.white.opacity(0.88), Color(red: 0.95, green: 0.93, blue: 0.87)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .stroke(Color.white.opacity(0.78), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.06), radius: 14, x: 0, y: 8)
    }
}

struct WarmIconTile: View {
    let systemName: String
    let tint: Color
    let size: CGFloat

    init(systemName: String, tint: Color, size: CGFloat = 52) {
        self.systemName = systemName
        self.tint = tint
        self.size = size
    }

    var body: some View {
        RoundedRectangle(cornerRadius: 18, style: .continuous)
            .fill(tint.opacity(0.92))
            .frame(width: size, height: size)
            .overlay(
                Image(systemName: systemName)
                    .foregroundColor(Color.black.opacity(0.55))
            )
    }
}

struct SoftUtilityHero: View {
    let title: String
    let subtitle: String
    let eyebrow: String?
    let titleSize: CGFloat

    init(title: String, subtitle: String, eyebrow: String? = nil, titleSize: CGFloat = 34) {
        self.title = title
        self.subtitle = subtitle
        self.eyebrow = eyebrow
        self.titleSize = titleSize
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.system(size: titleSize, weight: .bold, design: .rounded))
                .foregroundColor(.white)

            Text(subtitle)
                .foregroundColor(Color.white.opacity(0.76))

            if let eyebrow {
                SoftUtilityHeroChip(label: eyebrow)
            }
        }
        .premiumHeroStyle()
    }
}

struct SoftUtilityHeroChip: View {
    let label: String

    var body: some View {
        Text(label)
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(Color.white.opacity(0.12))
            .foregroundColor(.white)
            .clipShape(Capsule())
    }
}

struct SoftUtilityBulletRow: View {
    let text: String
    var systemImage: String = "checkmark.circle.fill"
    var tint: Color = .green

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: systemImage)
                .foregroundColor(tint)
            Text(text)
                .foregroundColor(.primary)
            Spacer()
        }
    }
}

struct SoftUtilityMetricTile: View {
    let label: String
    let value: String
    let caption: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Text(value)
                .font(.system(size: 26, weight: .bold, design: .rounded))
            if let caption {
                Text(caption)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .metricTileStyle()
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

    func softUtilityBackground() -> some View {
        modifier(SoftUtilityBackground())
    }

    func warmAppBackground(top: Color = Color(red: 0.94, green: 0.93, blue: 0.89), middle: Color = Color(red: 0.90, green: 0.91, blue: 0.87)) -> some View {
        modifier(WarmAppBackground(top: top, middle: middle))
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
