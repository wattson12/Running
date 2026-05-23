import Foundation
import XCTestDynamicOverlay

extension HealthKitObservation {
    static let previewValue: HealthKitObservation = .init(
        enableBackgroundDelivery: {},
        observeWorkouts: {}
    )

    static let testValue: HealthKitObservation = .init()
}
