import Dependencies
import Foundation
import XCTestDynamicOverlay

extension HealthKitSupport {
    static let previewValue: HealthKitSupport = .init(
        isHealthKitDataAvailable: { true }
    )

    static let testValue: HealthKitSupport = .init()
}
