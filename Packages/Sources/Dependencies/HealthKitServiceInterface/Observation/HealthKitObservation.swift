import Foundation
import HealthKit

public struct HealthKitObservation: Sendable {
    public var _enableBackgroundDelivery: @Sendable () async throws -> Void
    public var _observeWorkouts: @Sendable () async throws -> Void

    public init(
        enableBackgroundDelivery: @Sendable @escaping () async throws -> Void,
        observeWorkouts: @Sendable @escaping () async throws -> Void
    ) {
        _enableBackgroundDelivery = enableBackgroundDelivery
        _observeWorkouts = observeWorkouts
    }
}

public extension HealthKitObservation {
    func enableBackgroundDelivery() async throws {
        try await _enableBackgroundDelivery()
    }

    func observeWorkouts() async throws {
        try await _observeWorkouts()
    }
}
