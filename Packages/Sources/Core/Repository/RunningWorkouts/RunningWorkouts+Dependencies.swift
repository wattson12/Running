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
            runDetail: { _ in
                .mock()
            }
        )
    }

    static var previewValue: RunningWorkouts = .mock(runs: .allRuns)

    static var testValue: RunningWorkouts = .init(
        allRunningWorkouts: unimplemented(
            "RunningWorkouts.allRunningWorkouts",
            placeholder: .init(cache: { nil }, remote: { [] })
        ),
        runDetail: unimplemented("RunningWorkouts.runDetail", placeholder: .mock())
    )
}
