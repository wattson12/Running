import Foundation
import HealthKit
import XCTestDynamicOverlay
import ConcurrencyExtras

protocol HealthStoreType: Sendable {
    func statusForAuthorizationRequest(
        toShare typesToShare: Set<HKSampleType>,
        read typesToRead: Set<HKObjectType>
    ) async throws -> HKAuthorizationRequestStatus

    func requestAuthorization(
        toShare typesToShare: Set<HKSampleType>,
        read typesToRead: Set<HKObjectType>
    ) async throws

    static func isHealthDataAvailable() -> Bool
}

struct MockHealthStoreType: HealthStoreType {
    let _statusForAuthorizationRequest: LockIsolated<@Sendable (Set<HKSampleType>, Set<HKObjectType>) async throws -> HKAuthorizationRequestStatus>
    func statusForAuthorizationRequest(
        toShare typesToShare: Set<HKSampleType>,
        read typesToRead: Set<HKObjectType>
    ) async throws -> HKAuthorizationRequestStatus {
        try await _statusForAuthorizationRequest.value(typesToShare, typesToRead)
    }

    let _requestAuthorization: LockIsolated< @Sendable (Set<HKSampleType>, Set<HKObjectType>) async throws -> Void>
    func requestAuthorization(
        toShare typesToShare: Set<HKSampleType>,
        read typesToRead: Set<HKObjectType>
    ) async throws {
        try await _requestAuthorization.value(typesToShare, typesToRead)
    }

    static let _isHealthDataAvailable: LockIsolated<@Sendable () -> Bool> = .init(unimplemented(placeholder: false))
    static func isHealthDataAvailable() -> Bool {
        _isHealthDataAvailable.value()
    }
    
    init(
        _statusForAuthorizationRequest: @Sendable @escaping (Set<HKSampleType>, Set<HKObjectType>) async throws -> HKAuthorizationRequestStatus = unimplemented(),
        _requestAuthorization: @Sendable @escaping (Set<HKSampleType>, Set<HKObjectType>) async throws -> Void = unimplemented()
    ) {
        self._statusForAuthorizationRequest = .init(_statusForAuthorizationRequest)
        self._requestAuthorization = .init(_requestAuthorization)
    }

}

extension HKHealthStore: HealthStoreType {}
