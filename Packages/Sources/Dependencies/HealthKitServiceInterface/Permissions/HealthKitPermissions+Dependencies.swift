import Dependencies
import Foundation
import XCTestDynamicOverlay

extension HealthKitPermissions {
    static let previewValue: HealthKitPermissions = .init(
        authorizationRequestStatus: { .unknown },
        requestAuthorization: {}
    )

    static let testValue: HealthKitPermissions = .init()
}
