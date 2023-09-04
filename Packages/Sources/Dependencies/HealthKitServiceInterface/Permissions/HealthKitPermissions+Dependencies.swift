import Dependencies
import Foundation
import XCTestDynamicOverlay

extension HealthKitPermissions {
    static var previewValue: HealthKitPermissions = .init(
        authorizationRequestStatus: { .unknown },
        requestAuthorization: {}
    )

    static var testValue: HealthKitPermissions = .init(
        authorizationRequestStatus: unimplemented("HealthKitPermissions.authorizationRequestStatus"),
        requestAuthorization: unimplemented("HealthKitPermissions.requestAuthorization")
    )
}
