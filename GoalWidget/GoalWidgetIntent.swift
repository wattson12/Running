import AppIntents
import Foundation
import WidgetKit

public struct GoalWidgetIntent: WidgetConfigurationIntent {
    public static let title: LocalizedStringResource = "Configuration"
    public static let description = IntentDescription("This is an example widget.")

    public init() {}

    @Parameter(title: "Period", default: .weekly)
    var period: Period
}
