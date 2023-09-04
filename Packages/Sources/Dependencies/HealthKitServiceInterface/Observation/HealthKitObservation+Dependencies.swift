import Foundation
import XCTestDynamicOverlay

extension HealthKitObservation {
    static var previewValue: HealthKitObservation = .init(
        enableBackgroundDelivery: {},
        observeWorkouts: {}
    )

    static var testValue: HealthKitObservation = .init(
        enableBackgroundDelivery: unimplemented("HealthKitObservation.enableBackgroundDelivery"),
        observeWorkouts: unimplemented("HealthKitObservation.observeWorkouts")
    )
}
