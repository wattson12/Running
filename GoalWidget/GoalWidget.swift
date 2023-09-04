import Foundation
import SwiftUI
import WidgetKit

public struct GoalWidget: Widget {
    public init() {}

    public var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: "GoalWidgetKind",
            intent: GoalWidgetIntent.self,
            provider: GoalTimelineProvider(),
            content: { entry in
                GoalWidgetView(entry: entry)
                    .containerBackground(.regularMaterial, for: .widget)
            }
        )
        .configurationDisplayName("Goal Progress")
        .description("Shows an overview of progress within a current goal")
        .supportedFamilies([.systemSmall])
    }
}

#Preview(
    "Default",
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
