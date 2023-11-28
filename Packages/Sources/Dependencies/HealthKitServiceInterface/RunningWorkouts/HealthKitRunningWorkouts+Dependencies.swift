import Dependencies
import Foundation
import XCTestDynamicOverlay

extension HealthKitRunningWorkouts {
    static var previewValue: HealthKitRunningWorkouts = .init(
        allRunningWorkouts: { [] },
        detail: { _ in .init(locations: [], samples: []) }
    )

    static var testValue: HealthKitRunningWorkouts = .init()
}
