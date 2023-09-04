import Foundation
import Model

public enum RunningWorkoutsError: Error {
    case validation(String)
}

// @unchecked because RepositorySource<Void, _> isnt Sendable
public struct RunningWorkouts: @unchecked Sendable {
    public var _allRunningWorkouts: () -> RepositorySource<Void, [Run]>
    public var _runsWithinGoal: @Sendable (Goal) throws -> [Run]

    public init(
        allRunningWorkouts: @escaping () -> RepositorySource<Void, [Run]>,
        runsWithinGoal: @Sendable @escaping (Goal) throws -> [Run]
    ) {
        _allRunningWorkouts = allRunningWorkouts
        _runsWithinGoal = runsWithinGoal
    }

    public init(
        allRunningWorkouts: RepositorySource<Void, [Run]>,
        runsWithinGoal: @Sendable @escaping (Goal) throws -> [Run]
    ) {
        _allRunningWorkouts = { allRunningWorkouts }
        _runsWithinGoal = runsWithinGoal
    }
}

public extension RunningWorkouts {
    var allRunningWorkouts: RepositorySource<Void, [Run]> {
        _allRunningWorkouts()
    }

    func runs(within goal: Goal) throws -> [Run] {
        try _runsWithinGoal(goal)
    }
}
