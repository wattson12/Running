import Foundation
import HealthKit

public struct HealthKitRunningWorkouts: Sendable {
    public var _allRunningWorkouts: @Sendable () async throws -> [WorkoutType]

    public init(
        allRunningWorkouts: @Sendable @escaping () async throws -> [WorkoutType]
    ) {
        _allRunningWorkouts = allRunningWorkouts
    }
}

public extension HealthKitRunningWorkouts {
    func allRunningWorkouts() async throws -> [WorkoutType] {
        try await _allRunningWorkouts()
    }
}
