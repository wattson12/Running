import DependenciesMacros
import Foundation
import HealthKit
import Model

@DependencyClient
public struct Permissions: Sendable {
    public var _authorizationRequestStatus: @Sendable () async throws -> AuthorizationRequestStatus
    public var _requestAuthorization: @Sendable () async throws -> Void

    public init(
        authorizationRequestStatus: @Sendable @escaping () async throws -> AuthorizationRequestStatus,
        requestAuthorization: @Sendable @escaping () async throws -> Void
    ) {
        _authorizationRequestStatus = authorizationRequestStatus
        _requestAuthorization = requestAuthorization
    }
}

public extension Permissions {
    func authorizationRequestStatus() async throws -> AuthorizationRequestStatus {
        try await _authorizationRequestStatus()
    }

    func requestAuthorization() async throws {
        try await _requestAuthorization()
    }
}
