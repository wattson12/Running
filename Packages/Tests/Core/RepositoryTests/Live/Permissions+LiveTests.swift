import Dependencies
import HealthKitServiceInterface
import Model
@testable import Repository
import Testing
import Foundation

@MainActor
struct Permissions_LiveTests {
    @Test func authorizationRequestStatusUsesCorrectFunctionFromHealthKitService() async throws {
        let sut: Permissions = withDependencies {
            $0.healthKit.permissions._authorizationRequestStatus = { .shouldRequest }
        } operation: {
            .live()
        }

        let status = try await sut.authorizationRequestStatus()
        #expect(status == .shouldRequest)
    }

    @Test func requestAuthorizationUsesCorrectFunctionFromHealthKitService() async throws {
        let requestAuthorizationCalled: LockIsolated<Bool> = .init(false)
        let sut: Permissions = withDependencies {
            $0.healthKit.permissions._requestAuthorization = {
                requestAuthorizationCalled.setValue(true)
            }
        } operation: {
            .live()
        }

        try await sut.requestAuthorization()
        let requestAuthorizationCalledValue = requestAuthorizationCalled.value
        #expect(requestAuthorizationCalledValue == true)
    }
}
