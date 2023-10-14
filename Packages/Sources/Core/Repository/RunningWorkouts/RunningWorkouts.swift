import Foundation
import Model

public enum RunningWorkoutsError: Error {
    case validation(String)
}

// @unchecked because RepositorySource<Void, _> isnt Sendable
public struct RunningWorkouts: @unchecked Sendable {
    public var _allRunningWorkouts: () -> RepositorySource<Void, [Run]>
    public var _runDetail: @Sendable (Run.ID) async throws -> Run

    public init(
        allRunningWorkouts: @escaping () -> RepositorySource<Void, [Run]>,
        runDetail: @Sendable @escaping (Run.ID) async throws -> Run
    ) {
        _allRunningWorkouts = allRunningWorkouts
        _runDetail = runDetail
    }

    public init(
        allRunningWorkouts: RepositorySource<Void, [Run]>,
        runDetail: @Sendable @escaping (Run.ID) async throws -> Run
    ) {
        _allRunningWorkouts = { allRunningWorkouts }
        _runDetail = runDetail
    }
}

public extension RunningWorkouts {
    var allRunningWorkouts: RepositorySource<Void, [Run]> {
        _allRunningWorkouts()
    }

    func detail(for id: Run.ID) async throws -> Run {
        try await _runDetail(id)
    }
}
