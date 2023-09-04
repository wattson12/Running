import Foundation
import HealthKit

public struct HealthKitPermissions: Sendable {
    public var _authorizationRequestStatus: @Sendable () async throws -> HKAuthorizationRequestStatus
    public var _requestAuthorization: @Sendable () async throws -> Void

    public init(
        authorizationRequestStatus: @Sendable @escaping () async throws -> HKAuthorizationRequestStatus,
        requestAuthorization: @Sendable @escaping () async throws -> Void
    ) {
        _authorizationRequestStatus = authorizationRequestStatus
        _requestAuthorization = requestAuthorization
    }
}

public extension HealthKitPermissions {
    func authorizationRequestStatus() async throws -> HKAuthorizationRequestStatus {
        try await _authorizationRequestStatus()
    }

    func requestAuthorization() async throws {
        try await _requestAuthorization()
    }
}
