import Foundation
import HealthKit

public struct HealthKitRunningWorkouts: Sendable {
    public var _allRunningWorkouts: @Sendable () async throws -> [WorkoutType]
    public var _runningWorkouts: @Sendable () -> AsyncThrowingStream<WorkoutType, Error>
    public var _detail: @Sendable (UUID) async throws -> Void

    public init(
        allRunningWorkouts: @Sendable @escaping () async throws -> [WorkoutType],
        runningWorkouts: @Sendable @escaping () -> AsyncThrowingStream<WorkoutType, Error>,
        detail: @Sendable @escaping (UUID) async throws -> Void
    ) {
        _allRunningWorkouts = allRunningWorkouts
        _runningWorkouts = runningWorkouts
        _detail = detail
    }
}

public extension HealthKitRunningWorkouts {
    func allRunningWorkouts() async throws -> [WorkoutType] {
        try await _allRunningWorkouts()
    }
}
