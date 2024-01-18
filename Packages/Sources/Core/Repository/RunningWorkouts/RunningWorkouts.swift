import Dependencies
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

    public var _cachedRun: @Sendable (Run.ID) -> Run?
    public var _runDetail: @Sendable (Run.ID) async throws -> Run
    public var _runsWithinGoal: @Sendable (Goal, Date) throws -> [Run]

    public init(
        allRunningWorkouts: @escaping () -> RepositorySource<Void, [Run]>,
        cachedRun: @Sendable @escaping (Run.ID) -> Run?,
        runDetail: @Sendable @escaping (Run.ID) async throws -> Run,
        runsWithinGoal: @Sendable @escaping (Goal, Date) throws -> [Run]
    ) {
        _allRunningWorkouts = allRunningWorkouts
        _cachedRun = cachedRun
        _runDetail = runDetail
        _runsWithinGoal = runsWithinGoal
    }

    public init(
        allRunningWorkouts: RepositorySource<Void, [Run]>,
        cachedRun: @Sendable @escaping (Run.ID) -> Run?,
        runDetail: @Sendable @escaping (Run.ID) async throws -> Run,
        runsWithinGoal: @Sendable @escaping (Goal, Date) throws -> [Run]
    ) {
        _allRunningWorkouts = { allRunningWorkouts }
        _cachedRun = cachedRun
        _runDetail = runDetail
        _runsWithinGoal = runsWithinGoal
    }
}

public extension RunningWorkouts {
    var allRunningWorkouts: RepositorySource<Void, [Run]> {
        _allRunningWorkouts()
    }

    func cachedRun(for id: Run.ID) -> Run? {
        _cachedRun(id)
    }

    func detail(for id: Run.ID) async throws -> Run {
        try await _runDetail(id)
    }

    func runs(within goal: Goal, date: Date? = nil) throws -> [Run] {
        @Dependency(\.date) var dateGenerator
        return try _runsWithinGoal(goal, date ?? dateGenerator.now)
    }
}
