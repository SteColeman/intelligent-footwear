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

extension View {
    func softPanelStyle() -> some View {
        modifier(SoftPanelModifier())
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
}
