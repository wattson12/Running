import Foundation
import Model
import WidgetKit

public struct GoalEntry: TimelineEntry {
    public let date: Date
    public let period: Goal.Period
    public let progress: Double?
    public let distance: Measurement<UnitLength>
    public let target: Measurement<UnitLength>?
    public let missingPermissions: Bool

    public init(
        date: Date,
        period: Goal.Period,
        progress: Double?,
        distance: Measurement<UnitLength>,
        target: Measurement<UnitLength>?,
        missingPermissions: Bool
    ) {
        self.date = date
        self.period = period
        self.progress = progress
        self.distance = distance
        self.target = target
        self.missingPermissions = missingPermissions
    }
}
