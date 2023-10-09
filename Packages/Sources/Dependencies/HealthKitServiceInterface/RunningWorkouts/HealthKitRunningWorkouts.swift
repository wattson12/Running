import Foundation
import HealthKit

public struct HealthKitRunningWorkouts: Sendable {
    public var _allRunningWorkouts: @Sendable () async throws -> [WorkoutType]
    public var _runningWorkouts: @Sendable () -> AsyncThrowingStream<WorkoutType, Error>

    public init(
        allRunningWorkouts: @Sendable @escaping () async throws -> [WorkoutType],
        runningWorkouts: @Sendable @escaping () -> AsyncThrowingStream<WorkoutType, Error>
    ) {
        _allRunningWorkouts = allRunningWorkouts
        _runningWorkouts = runningWorkouts
    }
}

public extension HealthKitRunningWorkouts {
    func allRunningWorkouts() async throws -> [WorkoutType] {
        try await _allRunningWorkouts()
    }
}
