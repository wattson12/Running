import Dependencies
import Model
import XCTestDynamicOverlay

extension RunningWorkouts {
    public static func mock(runs: [Run]) -> RunningWorkouts {
        @Dependency(\.calendar) var calendar
        @Dependency(\.date) var date

        return .init(
            allRunningWorkouts: .init(
                cache: { runs },
                remote: { runs }
            ),
            runsWithinGoal: { goal in
                let allRunningWorkouts: [Run] = runs
                guard let range = goal.period.startAndEnd(in: calendar, now: date()) else { return [] }
                return allRunningWorkouts
                    .filter { $0.startDate >= range.start && $0.startDate < range.end }
                    .sorted(by: { $0.startDate < $1.startDate })
            }
        )
    }

    static var previewValue: RunningWorkouts = .mock(runs: .allRuns)

    static var testValue: RunningWorkouts = .init(
        allRunningWorkouts: unimplemented(
            "RunningWorkouts.allRunningWorkouts",
            placeholder: .init(cache: { nil }, remote: { [] })
        ),
        runsWithinGoal: unimplemented("RunningWorkouts.runsWithinGoal", placeholder: [])
    )
}
