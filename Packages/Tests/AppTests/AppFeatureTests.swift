@testable import App
import ComposableArchitecture
import FeatureFlags
@testable import GoalList
import RunList
import SwiftUI
import Widgets
import Testing
import Foundation

@MainActor
@Suite
struct AppFeatureTests {
    @Test func runListIsRefreshedOnAppearance() async throws {
        let store = TestStore(
            initialState: .init(),
            reducer: AppFeature.init,
            withDependencies: {
                $0.repository.runningWorkouts._allRunningWorkouts = { .mock(value: []) }
                $0.repository.runningWorkouts._runsWithinGoal = { _, _ in [] }

                $0.repository.goals._goal = { period in .mock(period: period) }

                $0.uuid = .incrementing

                $0.widget._reloadAllTimelines = {}

                $0.healthKit.observation._enableBackgroundDelivery = {}
                $0.healthKit.observation._observeWorkouts = {}

                $0.date = .incrementing()
            }
        )

        store.exhaustivity = .off

        await store.send(\.view.onAppear)

        await store.receive(\.runList.delegate.runsRefreshed)
    }

    @Test func runListRunsRefreshedDelegateRefreshesGoalList() async throws {
        let store = TestStore(
            initialState: .init(),
            reducer: AppFeature.init,
            withDependencies: {
                $0.repository.goals._goal = { period in
                    .mock(period: period, target: .init(value: 1, unit: .kilometers))
                }
                $0.repository.runningWorkouts._runsWithinGoal = { _, _ in [] }

                $0.date = .incrementing()
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

    @Test func permissionsStateIsClearedOncePermissionsAreAvailable() async throws {
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

    @Test func deepLinkHandlingForGoalsDeepLink() async throws {
        let store = TestStore(
            initialState: .init(
                permissions: .init(state: .initial),
                tab: .runs,
                runList: .init(),
                goalList: .init()
            ),
            reducer: AppFeature.init
        )

        let url: URL = try #require(URL(string: "running://_/goals/weekly"))
        await store.send(.deepLink(url)) {
            $0.tab = .goals
        }
    }

    @Test func deepLinkHandlingForRunsDeepLink() async throws {
        let store = TestStore(
            initialState: .init(
                permissions: .init(state: .initial),
                tab: .goals,
                runList: .init(),
                goalList: .init()
            ),
            reducer: AppFeature.init
        )

        let url: URL = try #require(URL(string: "running://_/runs"))
        await store.send(.deepLink(url)) {
            $0.tab = .runs
        }
    }

    func testRunListIsRefresheOnScenePhaseChangeToActive() async throws {
        let store = TestStore(
            initialState: .init(),
            reducer: AppFeature.init,
            withDependencies: {
                $0.repository.runningWorkouts._allRunningWorkouts = { .mock(value: []) }
                $0.repository.runningWorkouts._runsWithinGoal = { _, _ in [] }

                $0.repository.goals._goal = { period in .mock(period: period) }

                $0.uuid = .incrementing

                $0.widget._reloadAllTimelines = {}

                $0.healthKit.observation._enableBackgroundDelivery = {}
                $0.healthKit.observation._observeWorkouts = {}

                $0.date = .incrementing()
            }
        )

        store.exhaustivity = .off

        await store.send(.view(.scenePhaseUpdated(.inactive, .active)))

        await store.receive(\.runList.delegate.runsRefreshed)
    }
}
