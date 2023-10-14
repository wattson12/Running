import Dependencies
import Foundation
import Model

public extension RunningWorkouts {
    func runs(
        within goal: Goal
    ) throws -> [Run] {
        @Dependency(\.calendar) var calendar
        @Dependency(\.date) var date

        let allRuns = allRunningWorkouts.cache() ?? []

        guard let interval = goal.period.startAndEnd(in: calendar, now: date.now) else {
            return allRuns
        }

        return allRuns.filter { $0.startDate >= interval.start && $0.startDate <= interval.end }
    }
}
