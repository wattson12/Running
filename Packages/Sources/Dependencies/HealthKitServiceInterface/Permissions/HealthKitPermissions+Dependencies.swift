import Dependencies
import Foundation
import XCTestDynamicOverlay

extension HealthKitPermissions {
    static var previewValue: HealthKitPermissions = .init(
        authorizationRequestStatus: { .unknown },
        requestAuthorization: {}
    )

    static var testValue: HealthKitPermissions = .init()
}
