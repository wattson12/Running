import DependenciesMacros
import Foundation
import Model

public enum RunningWorkoutsError: Error {
    case validation(String)
}

// @unchecked because RepositorySource<Void, _> isnt Sendable
@DependencyClient
public struct RunningWorkouts: @unchecked Sendable {
    public var _allRunningWorkouts: () -> RepositorySource<Void, [Run]> = {
        .init(
            cache: { nil },
            remote: { [] }
        )
    }

    public var _runDetail: @Sendable (Run.ID) async throws -> Run
    public var _runsWithinGoal: @Sendable (Goal) throws -> [Run]

    public init(
        allRunningWorkouts: @escaping () -> RepositorySource<Void, [Run]>,
        runDetail: @Sendable @escaping (Run.ID) async throws -> Run,
        runsWithinGoal: @Sendable @escaping (Goal) throws -> [Run]
    ) {
        _allRunningWorkouts = allRunningWorkouts
        _runDetail = runDetail
        _runsWithinGoal = runsWithinGoal
    }

    public init(
        allRunningWorkouts: RepositorySource<Void, [Run]>,
        runDetail: @Sendable @escaping (Run.ID) async throws -> Run,
        runsWithinGoal: @Sendable @escaping (Goal) throws -> [Run]
    ) {
        _allRunningWorkouts = { allRunningWorkouts }
        _runDetail = runDetail
        _runsWithinGoal = runsWithinGoal
    }
}

public extension RunningWorkouts {
    var allRunningWorkouts: RepositorySource<Void, [Run]> {
        _allRunningWorkouts()
    }

    func detail(for id: Run.ID) async throws -> Run {
        try await _runDetail(id)
    }

    func runs(within goal: Goal) throws -> [Run] {
        try _runsWithinGoal(goal)
    }
}
