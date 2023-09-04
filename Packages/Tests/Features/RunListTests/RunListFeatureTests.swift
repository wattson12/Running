import ComposableArchitecture
import DependenciesAdditions
import Foundation
import Model
import Repository
@testable import RunList
import XCTest

@MainActor
final class RunListFeatureTests: XCTestCase {
    func testRunsFetchedHappyPath() async throws {
        let allRuns: [Run] = .allRuns
        let runs: [Run] = Array(allRuns.suffix(5))
        for (index, run) in runs.enumerated() {
            print(index, run.id)
        }

        let store = TestStore(
            initialState: .init(),
            reducer: RunListFeature.init,
            withDependencies: {
                $0.userDefaults = .ephemeral()
                $0.repository.runningWorkouts._allRunningWorkouts = {
                    .mock(value: runs)
                }
                $0.date = .constant(.preview)
                $0.calendar = .current
                $0.uuid = .constant(.init(12))
                $0.widget._reloadAllTimelines = {}
            }
        )

        // fetch runs and setup sections on appearance
        await store.send(.view(.onAppear)) {
            $0.sections = [
                .init(
                    id: .init(12),
                    title: "Today",
                    runs: [
                        runs[4],
                    ]
                ),
                .init(
                    id: .init(12),
                    title: "December 22",
                    runs: [
                        runs[3],
                        runs[2],
                        runs[1],
                        runs[0],
                    ]
                ),
            ]
            $0.isLoading = true
        }

        // refreshed from cache
        await store.receive(.delegate(.runsRefreshed))

        await store.receive(._internal(.runsFetched(.success(runs)))) {
            $0.isLoading = false
        }

        // refreshed from remote
        await store.receive(.delegate(.runsRefreshed))

        await store.receive(._internal(.runsFetched(.success(runs))))

        await store.receive(.delegate(.runsRefreshed))
    }

    func testRunsFetchedReloadsWidgets() async throws {
        let reloadTimelinesCalled = expectation(description: "reload timelines called")

        let store = TestStore(
            initialState: .init(),
            reducer: RunListFeature.init,
            withDependencies: {
                $0.uuid = .incrementing
                $0.widget._reloadAllTimelines = {
                    reloadTimelinesCalled.fulfill()
                }
            }
        )

        store.exhaustivity = .off

        await store.send(._internal(.runsFetched(.success([]))))

        await fulfillment(of: [reloadTimelinesCalled])
    }
}
