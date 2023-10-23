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

        if let cachedRuns = runningWorkouts.allRunningWorkouts.cache() {
            runs = cachedRuns
        } else if userDefaults.bool(forKey: .initialImportCompleted) != true {
            isInitialImport = true
        }

        return .concatenate(
            .send(.delegate(.runsRefreshed)),
            .run { send in
                do {
                    for try await runs in runningWorkouts.allRunningWorkouts.stream() {
                        await send(._internal(.runsFetched(.success(runs))))
                    }
                } catch {
                    await send(._internal(.runsFetched(.failure(error))))
                }
            }
        )
    }
}
