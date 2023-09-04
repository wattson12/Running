import HealthKit
import HealthKitServiceInterface
@testable import HealthKitServiceLive
import XCTest

final class Permissions_LiveTests: XCTestCase {
    func testAuthorizationRequestStatus() async throws {
        let possibleStatus: [HKAuthorizationRequestStatus] = [
            .shouldRequest,
            .unknown,
            .unnecessary,
        ]

        let expectedStatus: HKAuthorizationRequestStatus = try XCTUnwrap(possibleStatus.randomElement())

        let store = MockHealthStoreType(
            _statusForAuthorizationRequest: { share, read in
                XCTAssertEqual(share, .sharePermissions)
                XCTAssertEqual(read, .readPermissions)
                return expectedStatus
            }
        )

        let sut: HealthKitPermissions = .live(store: store)

        let status = try await sut.authorizationRequestStatus()
        XCTAssertEqual(status, expectedStatus)
    }

    func testRequestAuthorization() async throws {
        let expectation = expectation(description: "requestAuthorization called")
        let store = MockHealthStoreType(
            _requestAuthorization: { share, read in
                XCTAssertEqual(share, .sharePermissions)
                XCTAssertEqual(read, .readPermissions)
                expectation.fulfill()
            }
        )

        let sut: HealthKitPermissions = .live(store: store)

        try await sut.requestAuthorization()

        await fulfillment(of: [expectation])
    }
}
