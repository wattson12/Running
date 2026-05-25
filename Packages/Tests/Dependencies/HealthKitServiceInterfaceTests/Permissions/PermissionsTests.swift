@testable import HealthKitServiceInterface
import Testing
import Foundation

struct PermissionsTests {
    @Test func authorizationRequestStatusPublicHelper() async throws {
        let sut: HealthKitPermissions = .init(
            authorizationRequestStatus: { .shouldRequest },
            requestAuthorization: { Issue.record() }
        )

        let status = try await sut.authorizationRequestStatus()
        #expect(status == .shouldRequest)
    }

    @Test func requestAuthorizationPublicHelper() async throws {
        let sut: HealthKitPermissions = .init(
            authorizationRequestStatus: {
                Issue.record()
                return .unknown
            },
            requestAuthorization: {}
        )

        try await sut.requestAuthorization()
    }
}
