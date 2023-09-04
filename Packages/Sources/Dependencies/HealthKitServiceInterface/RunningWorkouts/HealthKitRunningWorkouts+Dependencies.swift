import Dependencies
import Foundation
import XCTestDynamicOverlay

extension HealthKitRunningWorkouts {
    static var previewValue: HealthKitRunningWorkouts = .init(
        allRunningWorkouts: { [] }
    )

    static var testValue: HealthKitRunningWorkouts = .init(
        allRunningWorkouts: unimplemented("HealthKitRunningWorkouts.allRunningWorkouts", placeholder: [])
    )
}
