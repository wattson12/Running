import Foundation
import XCTestDynamicOverlay

extension HealthKitObservation {
    static var previewValue: HealthKitObservation = .init(
        enableBackgroundDelivery: {},
        observeWorkouts: {}
    )

    static var testValue: HealthKitObservation = .init()
}
