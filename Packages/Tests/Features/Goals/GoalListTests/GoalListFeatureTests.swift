import ComposableArchitecture
import EditGoal
import Foundation
import GoalDetail
@testable import GoalList
import Model
import Repository
import Widgets
import Testing
import Foundation

@MainActor
@Suite
struct GoalListFeatureTests {
    @Test func goalsPopulatedHappyPath() async throws {
        let weeklyRun: Run = .mock()
        let monthlyRun: Run = .mock()
        let yearlyRun: Run = .mock()

        let runs: [Goal.Period: [Run]] = [
            .weekly: [weeklyRun],
            .monthly: [monthlyRun],
            .yearly: [yearlyRun],
        ]

        let store = TestStore(
            initialState: .init(),
            reducer: GoalListFeature.init,
            withDependencies: {
                $0.repository.goals._goal = { period in
                    .mock(
                        period: period,
                        target: .init(value: 100, unit: .kilometers)
                    )
                }

                $0.repository.runningWorkouts._runsWithinGoal = { goal, _ in
                    runs[goal.period] ?? []
                }
                $0.repository.runningWorkouts._allRunningWorkouts = { .mock(value: []) }

                $0.widget._reloadAllTimelines = {}

                $0.date = .incrementing()
            }
        )

        // initial setup on appearance
        await store.send(.view(.onAppear)) {
            $0.weeklyGoal = .mock(
                period: .weekly,
                target: .init(value: 100, unit: .kilometers)
            )
            $0.weeklyRuns = runs[.weekly] ?? []

            $0.monthlyGoal = .mock(
                period: .monthly,
                target: .init(value: 100, unit: .kilometers)
            )
            $0.monthlyRuns = runs[.monthly] ?? []

            $0.yearlyGoal = .mock(
                period: .yearly,
                target: .init(value: 100, unit: .kilometers)
            )
            $0.yearlyRuns = runs[.yearly] ?? []

            $0.rows = [
                .init(
                    goal: .mock(
                        period: .weekly,
                        target: .init(value: 100, unit: .kilometers)
                    ),
                    distance: weeklyRun.distance
                ),
                .init(
                    goal: .mock(
                        period: .monthly,
                        target: .init(value: 100, unit: .kilometers)
                    ),
                    distance: monthlyRun.distance
                ),
                .init(
                    goal: .mock(
                        period: .yearly,
                        target: .init(value: 100, unit: .kilometers)
                    ),
                    distance: yearlyRun.distance
                ),
            ]
        }
    }

    @Test func goalsPopulatedWhenSomeGoalsHaveNoRuns() async throws {
        let weeklyRun: Run = .mock()
        let yearlyRun: Run = .mock()
        let runs: [Goal.Period: [Run]] = [
            .weekly: [weeklyRun],
            .monthly: [],
            .yearly: [yearlyRun],
        ]

        let store = TestStore(
            initialState: .init(),
            reducer: GoalListFeature.init,
            withDependencies: {
                $0.repository.goals._goal = { period in
                    .mock(
                        period: period,
                        target: .init(value: 100, unit: .kilometers)
                    )
                }

                $0.repository.runningWorkouts._runsWithinGoal = { goal, _ in
                    runs[goal.period] ?? []
                }
                $0.repository.runningWorkouts._allRunningWorkouts = { .mock(value: []) }

                $0.widget._reloadAllTimelines = {}

                $0.date = .incrementing()
            }
        )

        // initial setup on appearance
        await store.send(.view(.onAppear)) {
            $0.weeklyGoal = .mock(
                period: .weekly,
                target: .init(value: 100, unit: .kilometers)
            )
            $0.weeklyRuns = runs[.weekly] ?? []

            $0.monthlyGoal = .mock(
                period: .monthly,
                target: .init(value: 100, unit: .kilometers)
            )
            $0.monthlyRuns = runs[.monthly] ?? []

            $0.yearlyGoal = .mock(
                period: .yearly,
                target: .init(value: 100, unit: .kilometers)
            )
            $0.yearlyRuns = runs[.yearly] ?? []

            $0.rows = [
                .init(
                    goal: .mock(
                        period: .weekly,
                        target: .init(value: 100, unit: .kilometers)
                    ),
                    distance: weeklyRun.distance
                ),
                .init(
                    goal: .mock(
                        period: .monthly,
                        target: .init(value: 100, unit: .kilometers)
                    ),
                    distance: .init(value: 0, unit: .kilometers)
                ),
                .init(
                    goal: .mock(
                        period: .yearly,
                        target: .init(value: 100, unit: .kilometers)
                    ),
                    distance: yearlyRun.distance
                ),
            ]
        }
    }

    @Test func goalsPopulatedWhenFetchingSomeGoalsFails() async throws {
        let weeklyRun: Run = .mock()
        let yearlyRun: Run = .mock()
        let runs: [Goal.Period: [Run]] = [
            .weekly: [weeklyRun],
            .yearly: [yearlyRun],
        ]

        let failure = NSError(domain: #fileID, code: #line)

        let store = TestStore(
            initialState: .init(),
            reducer: GoalListFeature.init,
            withDependencies: {
                $0.repository.goals._goal = { period in
                    .mock(
                        period: period,
                        target: .init(value: 100, unit: .kilometers)
                    )
                }

                $0.repository.runningWorkouts._allRunningWorkouts = { .mock(value: []) }
                $0.repository.runningWorkouts._runsWithinGoal = { goal, _ in
                    if let runs = runs[goal.period] {
                        return runs
                    } else {
                        throw failure
                    }
                }

                $0.widget._reloadAllTimelines = {}

                $0.date = .incrementing()
            }
        )

        // initial setup on appearance
        await store.send(.view(.onAppear)) {
            $0.weeklyGoal = .mock(
                period: .weekly,
                target: .init(value: 100, unit: .kilometers)
            )
            $0.weeklyRuns = runs[.weekly] ?? []

            $0.monthlyGoal = nil
            $0.monthlyRuns = []

            $0.yearlyGoal = .mock(
                period: .yearly,
                target: .init(value: 100, unit: .kilometers)
            )
            $0.yearlyRuns = runs[.yearly] ?? []

            $0.rows = [
                .init(
                    goal: .mock(
                        period: .weekly,
                        target: .init(value: 100, unit: .kilometers)
                    ),
                    distance: weeklyRun.distance
                ),
                .init(
                    goal: .mock(
                        period: .yearly,
                        target: .init(value: 100, unit: .kilometers)
                    ),
                    distance: yearlyRun.distance
                ),
            ]
        }
    }

    @Test func destinationIsCorrectWhenTappingGoalWithTarget() async throws {
        let goal: Goal = .mock(
            period: .weekly,
            target: .init(value: 100, unit: .kilometers)
        )

        let store = TestStore(
            initialState: .init(
                weeklyGoal: goal
            ),
            reducer: GoalListFeature.init
        )

        await store.send(.view(.goalTapped(goal))) {
            $0.destination = .detail(.init(goal: goal))
        }
    }

    @Test func destinationIsCorrectWhenTappingGoalWithoutTarget() async throws {
        let goal: Goal = .mock(
            period: .weekly,
            target: nil
        )

        let store = TestStore(
            initialState: .init(
                weeklyGoal: goal
            ),
            reducer: GoalListFeature.init
        )

        await store.send(.view(.goalTapped(goal))) {
            $0.destination = .detail(.init(goal: goal))
        }
    }

    @Test func destinationIsCorrectWhenEditGoalTapped() async throws {
        let goal: Goal = .mock(
            period: .weekly,
            target: .init(value: 100, unit: .kilometers)
        )

        let store = TestStore(
            initialState: .init(
                weeklyGoal: goal
            ),
            reducer: GoalListFeature.init
        )

        await store.send(.view(.editTapped(goal))) {
            $0.destination = .editGoal(.init(goal: goal))
        }
    }

    @Test func editGoalGoalUpdatedDelegateUpdatesStateAndCacheForWeeklyGoal() async throws {
        let goal: Goal = .mock(
            period: .weekly,
            target: .init(value: 1, unit: .kilometers)
        )

        let updatedGoal: Goal = .mock(
            period: .weekly,
            target: .init(
                value: .random(in: 1 ..< 100),
                unit: .kilometers
            )
        )

        let store = TestStore(
            initialState: .init(
                weeklyGoal: goal,
                destination: .editGoal(.init(goal: goal))
            ),
            reducer: GoalListFeature.init,
            withDependencies: {
                $0.repository.goals._updateGoal = {
                    #expect($0 == updatedGoal)
                }
                $0.widget._reloadAllTimelines = {}
            }
        )

        await store.send(\.destination.editGoal.delegate.goalUpdated, updatedGoal) {
            $0.weeklyGoal = updatedGoal
            $0.refreshRows()
            $0.destination = nil
        }
    }

    @Test func editGoalGoalUpdatedDelegateUpdatesStateAndCacheForMonthlyGoal() async throws {
        let goal: Goal = .mock(
            period: .monthly,
            target: .init(value: 1, unit: .kilometers)
        )

        let updatedGoal: Goal = .mock(
            period: .monthly,
            target: .init(
                value: .random(in: 1 ..< 100),
                unit: .kilometers
            )
        )

        let store = TestStore(
            initialState: .init(
                monthlyGoal: goal,
                destination: .editGoal(.init(goal: goal))
            ),
            reducer: GoalListFeature.init,
            withDependencies: {
                $0.repository.goals._updateGoal = {
                    #expect($0 == updatedGoal)
                }
                $0.widget._reloadAllTimelines = {}
            }
        )

        await store.send(\.destination.editGoal.delegate.goalUpdated, updatedGoal) {
            $0.monthlyGoal = updatedGoal
            $0.refreshRows()
            $0.destination = nil
        }
    }

    @Test func editGoalGoalUpdatedDelegateUpdatesStateAndCacheForYearlyGoal() async throws {
        let goal: Goal = .mock(
            period: .yearly,
            target: .init(value: 1, unit: .kilometers)
        )

        let updatedGoal: Goal = .mock(
            period: .yearly,
            target: .init(
                value: .random(in: 1 ..< 100),
                unit: .kilometers
            )
        )

        let store = TestStore(
            initialState: .init(
                yearlyGoal: goal,
                destination: .editGoal(.init(goal: goal))
            ),
            reducer: GoalListFeature.init,
            withDependencies: {
                $0.repository.goals._updateGoal = {
                    #expect($0 == updatedGoal)
                }
                $0.widget._reloadAllTimelines = {}
            }
        )

        await store.send(\.destination.editGoal.delegate.goalUpdated, updatedGoal) {
            $0.yearlyGoal = updatedGoal
            $0.refreshRows()
            $0.destination = nil
        }
    }

    @Test func editGoalGoalClearedDelegateUpdatesStateAndCacheForWeeklyGoal() async throws {
        let goal: Goal = .mock(
            period: .weekly,
            target: .init(value: 1, unit: .kilometers)
        )

        let updatedGoal: Goal = .mock(
            period: .weekly,
            target: nil
        )

        let store = TestStore(
            initialState: .init(
                weeklyGoal: goal,
                destination: .editGoal(.init(goal: goal))
            ),
            reducer: GoalListFeature.init,
            withDependencies: {
                $0.repository.goals._updateGoal = {
                    #expect($0 == updatedGoal)
                }
                $0.widget._reloadAllTimelines = {}
            }
        )

        await store.send(\.destination.editGoal.delegate.goalCleared, .weekly) {
            $0.weeklyGoal = updatedGoal
            $0.refreshRows()
            $0.destination = nil
        }
    }

    @Test func editGoalGoalClearedDelegateUpdatesStateAndCacheForMonthlyGoal() async throws {
        let goal: Goal = .mock(
            period: .monthly,
            target: .init(value: 1, unit: .kilometers)
        )

        let updatedGoal: Goal = .mock(
            period: .monthly,
            target: nil
        )

        let store = TestStore(
            initialState: .init(
                monthlyGoal: goal,
                destination: .editGoal(.init(goal: goal))
            ),
            reducer: GoalListFeature.init,
            withDependencies: {
                $0.repository.goals._updateGoal = {
                    #expect($0 == updatedGoal)
                }
                $0.widget._reloadAllTimelines = {}
            }
        )

        await store.send(\.destination.editGoal.delegate.goalCleared, .monthly) {
            $0.monthlyGoal = updatedGoal
            $0.refreshRows()
            $0.destination = nil
        }
    }

    @Test func editGoalGoalClearedDelegateUpdatesStateAndCacheForYearlyGoal() async throws {
        let goal: Goal = .mock(
            period: .yearly,
            target: .init(value: 1, unit: .kilometers)
        )

        let updatedGoal: Goal = .mock(
            period: .yearly,
            target: nil
        )

        let updateGoalCalled = LockIsolated<Bool>(false)
        let reloadTimelinesCalled =  LockIsolated<Bool>(false)
        
        let store = TestStore(
            initialState: .init(
                yearlyGoal: goal,
                destination: .editGoal(.init(goal: goal))
            ),
            reducer: GoalListFeature.init,
            withDependencies: {
                $0.repository.goals._updateGoal = {
                    #expect($0 == updatedGoal)
                    updateGoalCalled.setValue(true)
                }
                $0.widget._reloadAllTimelines = {
                    reloadTimelinesCalled.setValue(true)
                }
            }
        )

        await store.send(\.destination.editGoal.delegate.goalCleared, .yearly) {
            $0.yearlyGoal = updatedGoal
            $0.refreshRows()
            $0.destination = nil
        }

        #expect(updateGoalCalled.value)
        #expect(reloadTimelinesCalled.value)
    }

    @Test func deepLinkHandling() {
        let weekly: Goal = .mock(
            period: .weekly,
            target: .init(
                value: .random(in: 1 ..< 10000),
                unit: .kilometers
            )
        )

        let monthly: Goal = .mock(
            period: .monthly,
            target: .init(
                value: .random(in: 1 ..< 10000),
                unit: .kilometers
            )
        )

        let yearly: Goal = .mock(
            period: .yearly,
            target: .init(
                value: .random(in: 1 ..< 10000),
                unit: .kilometers
            )
        )

        var sut: GoalListFeature.State = .init(
            weeklyGoal: weekly,
            monthlyGoal: monthly,
            yearlyGoal: yearly
        )

        sut.handleDeepLink(route: .weekly(nil))
        #expect(sut.destination == .detail(.init(goal: weekly)))

        sut.destination = nil

        sut.handleDeepLink(route: .monthly(nil))
        #expect(sut.destination == .detail(.init(goal: monthly)))

        sut.destination = nil

        sut.handleDeepLink(route: .yearly(nil))
        #expect(sut.destination == .detail(.init(goal: yearly)))

        sut.destination = nil

        sut.handleDeepLink(route: .weekly(.edit))
        #expect(sut.destination == .editGoal(.init(goal: weekly)))

        sut.destination = nil

        sut.handleDeepLink(route: .monthly(.edit))
        #expect(sut.destination == .editGoal(.init(goal: monthly)))

        sut.destination = nil

        sut.handleDeepLink(route: .yearly(.edit))
        #expect(sut.destination == .editGoal(.init(goal: yearly)))
    }

    @Test func deepLinkHandlingWhenGoalIsNotFound() {
        var sut: GoalListFeature.State = .init(
            weeklyGoal: nil,
            monthlyGoal: nil,
            yearlyGoal: nil
        )

        sut.handleDeepLink(route: .weekly(nil))
        #expect(sut.destination == nil)

        sut.handleDeepLink(route: .monthly(nil))
        #expect(sut.destination == nil)

        sut.handleDeepLink(route: .yearly(nil))
        #expect(sut.destination == nil)
    }
}
