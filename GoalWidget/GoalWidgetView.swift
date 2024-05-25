import DesignSystem
import Foundation
import SwiftUI
import WidgetKit

struct CircularProgressView: View {
    let progress: Double
    let lineWidth: CGFloat
    @Environment(\.tintColor) var tint

    var body: some View {
        ZStack {
            Circle()
                .stroke(
                    tint.opacity(0.5),
                    lineWidth: lineWidth
                )
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    tint,
                    style: StrokeStyle(
                        lineWidth: lineWidth,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
        }
    }
}

extension NumberFormatter {
    static var percentage: NumberFormatter {
        let formatter = NumberFormatter()
        return formatter
    }
}

public struct GoalWidgetView: View {
    public var entry: GoalTimelineProvider.Entry
    @Environment(\.locale) var locale

    public init(
        entry: GoalTimelineProvider.Entry
    ) {
        self.entry = entry
    }

    public var body: some View {
        ZStack {
            if entry.progress == nil || entry.missingPermissions {
                CircularProgressView(
                    progress: entry.progress ?? 0,
                    lineWidth: 16
                )
                .customTint(entry.period.tint)
                .blur(radius: 3.0)
            } else {
                CircularProgressView(
                    progress: entry.progress ?? 0,
                    lineWidth: 16
                )
                .customTint(entry.period.tint)
            }

            VStack {
                if entry.missingPermissions {
                    Text("Tap to refresh workouts")
                        .multilineTextAlignment(.center)
                        .font(.title3.bold())
                } else if let progress = entry.progress {
                    Text(
                        progress,
                        format: .percent
                            .precision(.fractionLength(0 ..< 2))
                    )
                    .font(.title2.bold())
                    .foregroundStyle(.primary)
                    .contentTransition(.numericText())

                    Text(
                        entry.distance.fullValue(locale: locale)
                    )
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .contentTransition(.numericText())
                } else {
                    Text("Tap to set goal")
                        .multilineTextAlignment(.center)
                        .font(.title3.bold())
                }

                Text(entry.period.displayName)
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
            .padding(8)
        }
        .animation(.default, value: entry.progress)
        .widgetURL(widgetURL)
    }

    var widgetURL: URL? {
        if entry.missingPermissions {
            return URL(string: "running://_/permissions")
        } else if entry.target == nil {
            return URL(string: "running://_/goals/\(entry.period.rawValue)/edit")
        } else {
            return URL(string: "running://_/goals/\(entry.period.rawValue)")
        }
    }
}

#Preview(
    "With Goal",
    as: .systemSmall
) {
    GoalWidget()
} timeline: {
    GoalEntry(
        date: .now,
        period: .weekly,
        progress: 0.5,
        distance: .init(value: 50, unit: .kilometers),
        target: .init(value: 100, unit: .kilometers),
        missingPermissions: false
    )
}

#Preview(
    "Missing Target",
    as: .systemSmall
) {
    GoalWidget()
} timeline: {
    GoalEntry(
        date: .now,
        period: .weekly,
        progress: nil,
        distance: .init(value: 50, unit: .kilometers),
        target: nil,
        missingPermissions: false
    )
}

#Preview(
    "Missing Permissions",
    as: .systemSmall
) {
    GoalWidget()
} timeline: {
    GoalEntry(
        date: .now,
        period: .weekly,
        progress: nil,
        distance: .init(value: 50, unit: .kilometers),
        target: nil,
        missingPermissions: true
    )
}
