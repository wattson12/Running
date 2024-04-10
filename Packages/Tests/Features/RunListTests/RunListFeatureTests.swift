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
                $0.repository.runningWorkouts = .mock(runs: runs)
                $0.date = .constant(date)
                $0.calendar = .current
                $0.uuid = .constant(.init(12))
                $0.widget._reloadAllTimelines = {}
            }
        )

        // fetch runs and setup sections on appearance
        await store.send(.view(.onAppear)) {
            $0.runs = .init(uniqueElements: runs)
            $0.isLoading = true
        }

        // refreshed from cache
        await store.receive(\.delegate.runsRefreshed)

        await store.receive(\._internal.runsFetched.success) {
            $0.isLoading = false
        }

        // refreshed from remote
        await store.receive(\.delegate.runsRefreshed)
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

    func testTappingOnRunSetsCorrectDestinationWithFeatureFlagEnabled() async throws {
        let run: Run = .mock()
        let store = TestStore(
            initialState: .init(
                runs: [
                    .mock(),
                    run,
                    .mock(),
                ]
            ),
            reducer: RunListFeature.init,
            withDependencies: {
                $0.defaultAppStorage.set(true, forKey: "show_run_detail")
            }
        )

        await store.send(.view(.runTapped(run))) {
            $0.destination = .detail(.init(run: run))
        }
    }

    func testTappingOnRunDoesNothingWithFeatureFlagDisabled() async throws {
        let run: Run = .mock()
        let store = TestStore(
            initialState: .init(
                runs: [
                    .mock(),
                    run,
                    .mock(),
                ]
            ),
            reducer: RunListFeature.init,
            withDependencies: {
                $0.defaultAppStorage.set(false, forKey: "show_run_detail")
            }
        )

        await store.send(.view(.runTapped(run)))
    }
}
