import AppIntents
import Foundation
import WidgetKit

public struct GoalWidgetIntent: WidgetConfigurationIntent {
    public static var title: LocalizedStringResource = "Configuration"
    public static var description = IntentDescription("This is an example widget.")

    public init() {}

    @Parameter(title: "Period", default: .weekly)
    var period: Period
}
