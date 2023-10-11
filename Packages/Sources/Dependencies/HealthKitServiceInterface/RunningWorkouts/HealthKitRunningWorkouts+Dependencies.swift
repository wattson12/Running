import Dependencies
import Foundation
import XCTestDynamicOverlay

extension HealthKitRunningWorkouts {
    static var previewValue: HealthKitRunningWorkouts = .init(
        allRunningWorkouts: { [] },
        detail: { _ in }
    )

    static var testValue: HealthKitRunningWorkouts = .init(
        allRunningWorkouts: unimplemented("HealthKitRunningWorkouts.allRunningWorkouts", placeholder: []),
        detail: unimplemented("HealthKitRunningWorkouts.allRunningWorkouts")
    )
}
