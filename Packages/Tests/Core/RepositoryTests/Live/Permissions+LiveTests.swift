import Dependencies
import HealthKitServiceInterface
import Model
@testable import Repository
import XCTest

final class Permissions_LiveTests: XCTestCase {
    func testAuthorizationRequestStatusUsesCorrectFunctionFromHealthKitService() async throws {
        let sut: Permissions = withDependencies {
            $0.healthKit.permissions._authorizationRequestStatus = { .shouldRequest }
        } operation: {
            .live()
        }

        let status = try await sut.authorizationRequestStatus()
        XCTAssertEqual(status, .shouldRequest)
    }

    func testRequestAuthorizationUsesCorrectFunctionFromHealthKitService() async throws {
        let requestAuthorizationCalled: ActorIsolated<Bool> = .init(false)
        let sut: Permissions = withDependencies {
            $0.healthKit.permissions._requestAuthorization = {
                await requestAuthorizationCalled.setValue(true)
            }
        } operation: {
            .live()
        }

        try await sut.requestAuthorization()
        let requestAuthorizationCalledValue = await requestAuthorizationCalled.value
        XCTAssert(requestAuthorizationCalledValue)
    }
}
