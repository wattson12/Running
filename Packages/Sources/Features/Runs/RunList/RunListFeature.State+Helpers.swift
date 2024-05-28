import ComposableArchitecture
import Dependencies
import DependenciesAdditions
import Foundation
import Model
import Resources

public extension RunListFeature.State {
    mutating func refresh() -> Effect<RunListFeature.Action> {
        guard !isLoading else { return .none }

        @Dependency(\.userDefaults) var userDefaults
        @Dependency(\.repository.runningWorkouts) var runningWorkouts

        isLoading = true

        let cachedRunsEffect: Effect<RunListFeature.Action>
        if let cachedRuns = runningWorkouts.allRunningWorkouts.cache() {
            runs = .init(uniqueElements: cachedRuns.map(RunState.init))
            cachedRunsEffect = .send(.delegate(.runsRefreshed))
        } else if userDefaults.bool(forKey: .initialImportCompleted) != true {
            isInitialImport = true
            cachedRunsEffect = .none
        } else {
            cachedRunsEffect = .none
        }

        return .concatenate(
            cachedRunsEffect,
            .run { send in
                do {
                    let runs = try await runningWorkouts.allRunningWorkouts.remote()
                    await send(._internal(.runsFetched(.success(runs))))
                } catch {
                    await send(._internal(.runsFetched(.failure(error))))
                }
            }
        )
    }
}
