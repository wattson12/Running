import Dependencies
import Model
import XCTestDynamicOverlay

extension RunningWorkouts {
    public static func mock(runs: [Run]) -> RunningWorkouts {
        @Dependency(\.calendar) var calendar

        return .init(
            allRunningWorkouts: .init(
                cache: { runs },
                remote: { runs }
            ),
            cachedRun: { id in
                runs.first(where: { $0.id == id })
            },
            runDetail: { _ in
                .mock()
            },
            runsWithinGoal: { goal, date in
                let allRunningWorkouts: [Run] = runs
                guard let range = goal.period.startAndEnd(in: calendar, now: date) else { return [] }
                return allRunningWorkouts
                    .filter { $0.startDate >= range.start && $0.startDate < range.end }
                    .sorted(by: { $0.startDate < $1.startDate })
            }
        )
    }

    public static func newRun(initialRuns: [Run], newRun: Run) -> RunningWorkouts {
        @Dependency(\.calendar) var calendar
        @Dependency(\.date) var date
        let runs: LockIsolated<[Run]> = .init(initialRuns)

        return .init(
            allRunningWorkouts: .init(
                cache: { runs.value },
                remote: {
                    try await Task.sleep(for: .seconds(1))
                    var runsValue = runs.value
                    if runsValue.count == initialRuns.count {
                        runsValue.append(newRun)
                        let updatedRuns = runsValue
                        runs.setValue(updatedRuns)
                    }
                    return runsValue
                }
            ),
            cachedRun: { id in
                runs.value.first(where: { $0.id == id })
            },
            runDetail: { _ in
                .mock()
            },
            runsWithinGoal: { _, _ in
                let allRunningWorkouts: [Run] = runs.value
                return allRunningWorkouts
                    .sorted(by: { $0.startDate < $1.startDate })
            }
        )
    }

    static var previewValue: RunningWorkouts = .mock(runs: .allRuns)

    static var testValue: RunningWorkouts = .init()
}
