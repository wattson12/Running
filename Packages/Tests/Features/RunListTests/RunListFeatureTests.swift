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
        let date = Date(timeIntervalSinceReferenceDate: 765_123_456) // March 2025
        let allRuns: [Run] = withDependencies {
            $0.calendar = .current
            $0.date = .constant(date)
        } operation: {
            .allRuns
        }
        let runs: [Run] = Array(allRuns.sorted(by: { $0.startDate < $1.startDate }).suffix(5))
        let store = TestStore(
            initialState: .init(),
            reducer: RunListFeature.init,
            withDependencies: {
                $0.userDefaults = .ephemeral()
                $0.repository.runningWorkouts = .mock(runs: runs)
                $0.date = .constant(date)
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
                    title: "Yesterday",
                    runs: [
                        runs[3],
                    ]
                ),
                .init(
                    id: .init(12),
                    title: "March 25",
                    runs: [
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
