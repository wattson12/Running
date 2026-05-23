import Dependencies
import Foundation
import XCTestDynamicOverlay

extension HealthKitRunningWorkouts {
    static let previewValue: HealthKitRunningWorkouts = .init(
        allRunningWorkouts: { [] },
        detail: { _ in .init(locations: [], samples: []) }
    )

    static let testValue: HealthKitRunningWorkouts = .init()
}
