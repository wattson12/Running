@testable import HealthKitServiceInterface
import XCTest

final class PermissionsTests: XCTestCase {
    func testAuthorizationRequestStatusPublicHelper() async throws {
        let sut: HealthKitPermissions = .init(
            authorizationRequestStatus: { .shouldRequest },
            requestAuthorization: { XCTFail() }
        )

        let status = try await sut.authorizationRequestStatus()
        XCTAssertEqual(status, .shouldRequest)
    }

    func testRequestAuthorizationPublicHelper() async throws {
        let sut: HealthKitPermissions = .init(
            authorizationRequestStatus: {
                XCTFail()
                return .unknown
            },
            requestAuthorization: {}
        )

        try await sut.requestAuthorization()
    }
}
