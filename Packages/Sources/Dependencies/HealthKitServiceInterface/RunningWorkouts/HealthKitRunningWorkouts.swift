import Foundation
import HealthKit

public struct HealthKitRunningWorkouts: Sendable {
    public var _allRunningWorkouts: @Sendable () async throws -> [WorkoutType]
    public var _detail: @Sendable (UUID) async throws -> Void

    public init(
        allRunningWorkouts: @Sendable @escaping () async throws -> [WorkoutType],
        detail: @Sendable @escaping (UUID) async throws -> Void
    ) {
        _allRunningWorkouts = allRunningWorkouts
        _detail = detail
    }
}

public extension HealthKitRunningWorkouts {
    func allRunningWorkouts() async throws -> [WorkoutType] {
        try await _allRunningWorkouts()
    }
}
