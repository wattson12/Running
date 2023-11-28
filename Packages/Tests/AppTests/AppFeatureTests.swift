@testable import App
import ComposableArchitecture
@testable import GoalList
import RunList
import Widgets
import XCTest

@MainActor
final class AppFeatureTests: XCTestCase {
    func testRunListIsRefreshedOnAppearance() async throws {
        let store = TestStore(
            initialState: .init(),
            reducer: AppFeature.init,
            withDependencies: {
                $0.userDefaults = .ephemeral()

                $0.repository.runningWorkouts._allRunningWorkouts = { .mock(value: []) }
                $0.repository.runningWorkouts._runsWithinGoal = { _ in [] }

                $0.repository.goals._goal = { period in .mock(period: period) }

                $0.uuid = .incrementing

                $0.widget._reloadAllTimelines = {}

                $0.healthKit.observation._enableBackgroundDelivery = {}
                $0.healthKit.observation._observeWorkouts = {}
            }
        )

        store.exhaustivity = .off

        await store.send(.view(.onAppear))

        await store.receive(.runList(.delegate(.runsRefreshed)))
    }

    func testRunListRunsRefreshedDelegateRefreshesGoalList() async throws {
        let store = TestStore(
            initialState: .init(),
            reducer: AppFeature.init,
            withDependencies: {
                $0.repository.goals._goal = { period in
                    .mock(period: period, target: .init(value: 1, unit: .kilometers))
                }
                $0.repository.runningWorkouts._runsWithinGoal = { _ in [] }
            }
        )

        await store.send(.runList(.delegate(.runsRefreshed))) {
            $0.goalList.weeklyGoal = .mock(period: .weekly, target: .init(value: 1, unit: .kilometers))
            $0.goalList.monthlyGoal = .mock(period: .monthly, target: .init(value: 1, unit: .kilometers))
            $0.goalList.yearlyGoal = .mock(period: .yearly, target: .init(value: 1, unit: .kilometers))
            $0.goalList.rows = [
                .init(
                    goal: .mock(period: .weekly, target: .init(value: 1, unit: .kilometers)),
                    distance: .init(value: 0, unit: .kilometers)
                ),
                .init(
                    goal: .mock(period: .monthly, target: .init(value: 1, unit: .kilometers)),
                    distance: .init(value: 0, unit: .kilometers)
                ),
                .init(
                    goal: .mock(period: .yearly, target: .init(value: 1, unit: .kilometers)),
                    distance: .init(value: 0, unit: .kilometers)
                ),
            ]
        }
    }

    func testPermissionsStateIsClearedOncePermissionsAreAvailable() async throws {
        let store = TestStore(
            initialState: .init(
                permissions: .init(state: .initial),
                runList: .init(),
                goalList: .init()
            ),
            reducer: AppFeature.init
        )

        await store.send(.permissions(.delegate(.permissionsAvailable))) {
            $0.permissions = nil
        }
    }

    func testDeepLinkHandlingForGoalsDeepLink() async throws {
        let store = TestStore(
            initialState: .init(
                permissions: .init(state: .initial),
                tab: .runs,
                runList: .init(),
                goalList: .init()
            ),
            reducer: AppFeature.init
        )

        let url: URL = try XCTUnwrap(URL(string: "running://_/goals/weekly"))
        await store.send(.deepLink(url)) {
            $0.tab = .goals
        }
    }

    func testDeepLinkHandlingForRunsDeepLink() async throws {
        let store = TestStore(
            initialState: .init(
                permissions: .init(state: .initial),
                tab: .goals,
                runList: .init(),
                goalList: .init()
            ),
            reducer: AppFeature.init
        )

        let url: URL = try XCTUnwrap(URL(string: "running://_/runs"))
        await store.send(.deepLink(url)) {
            $0.tab = .runs
        }
    }
}
