import Foundation
import HealthKit
import XCTestDynamicOverlay

protocol HealthStoreType {
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
    var _statusForAuthorizationRequest: (Set<HKSampleType>, Set<HKObjectType>) async throws -> HKAuthorizationRequestStatus = unimplemented()
    func statusForAuthorizationRequest(
        toShare typesToShare: Set<HKSampleType>,
        read typesToRead: Set<HKObjectType>
    ) async throws -> HKAuthorizationRequestStatus {
        try await _statusForAuthorizationRequest(typesToShare, typesToRead)
    }

    var _requestAuthorization: (Set<HKSampleType>, Set<HKObjectType>) async throws -> Void = unimplemented()
    func requestAuthorization(
        toShare typesToShare: Set<HKSampleType>,
        read typesToRead: Set<HKObjectType>
    ) async throws {
        try await _requestAuthorization(typesToShare, typesToRead)
    }

    static var _isHealthDataAvailable: () -> Bool = unimplemented()
    static func isHealthDataAvailable() -> Bool {
        _isHealthDataAvailable()
    }
}

extension HKHealthStore: HealthStoreType {}
