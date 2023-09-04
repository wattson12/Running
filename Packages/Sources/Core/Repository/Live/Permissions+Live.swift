import Dependencies
import Foundation
import HealthKitServiceInterface
import Model

extension Permissions {
    static func live() -> Self {
        @Dependency(\.healthKit.permissions) var healthKitPermissions

        return .init(
            authorizationRequestStatus: {
                try await Implementation.authorizationRequestStatus(healthKitPermissions: healthKitPermissions)
            },
            requestAuthorization: {
                try await healthKitPermissions.requestAuthorization()
            }
        )
    }

    private enum Implementation {
        static func authorizationRequestStatus(
            healthKitPermissions: HealthKitPermissions
        ) async throws -> AuthorizationRequestStatus {
            let model = try await healthKitPermissions.authorizationRequestStatus()
            return AuthorizationRequestStatus(model: model)
        }
    }
}
