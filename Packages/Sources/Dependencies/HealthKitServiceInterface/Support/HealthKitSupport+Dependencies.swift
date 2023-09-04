import Dependencies
import Foundation
import XCTestDynamicOverlay

extension HealthKitSupport {
    static var previewValue: HealthKitSupport = .init(
        isHealthKitDataAvailable: { true }
    )

    static var testValue: HealthKitSupport = .init(
        isHealthKitDataAvailable: unimplemented("HealthKitSupport.isHealthKitDataAvailable", placeholder: false)
    )
}
