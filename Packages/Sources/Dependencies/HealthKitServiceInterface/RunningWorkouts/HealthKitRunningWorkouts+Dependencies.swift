import Dependencies
import Foundation
import XCTestDynamicOverlay

extension HealthKitRunningWorkouts {
    static var previewValue: HealthKitRunningWorkouts = .init(
        allRunningWorkouts: { [] },
        runningWorkouts: { .never },
        detail: { _ in }
    )

    static var testValue: HealthKitRunningWorkouts = .init(
        allRunningWorkouts: unimplemented("HealthKitRunningWorkouts.allRunningWorkouts", placeholder: []),
        runningWorkouts: unimplemented(),
        detail: unimplemented()
    )
}
