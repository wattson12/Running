import ComposableArchitecture
import EditGoal
import Foundation
import GoalDetail
@testable import GoalList
import Model
import Repository
import Widgets
import XCTest

final class GoalListFeatureTests: XCTestCase {
    @MainActor
    func testGoalsPopulatedHappyPath() async throws {
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

    @MainActor
    func testGoalsPopulatedWhenSomeGoalsHaveNoRuns() async throws {
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

    @MainActor
    func testGoalsPopulatedWhenFetchingSomeGoalsFails() async throws {
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

    @MainActor
    func testDestinationIsCorrectWhenTappingGoalWithTarget() async throws {
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

    @MainActor
    func testDestinationIsCorrectWhenTappingGoalWithoutTarget() async throws {
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

    @MainActor
    func testDestinationIsCorrectWhenEditGoalTapped() async throws {
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

    @MainActor
    func testEdiyGoalGoalUpdatedDelegateUpdatesStateAndCacheForWeeklyGoal() async throws {
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

        let updateGoalCalled = expectation(description: "udpateGoal called")
        let reloadTimelinesCalled = expectation(description: "reload timelines called")

        let store = TestStore(
            initialState: .init(
                weeklyGoal: goal,
                destination: .editGoal(.init(goal: goal))
            ),
            reducer: GoalListFeature.init,
            withDependencies: {
                $0.repository.goals._updateGoal = {
                    XCTAssertEqual($0, updatedGoal)
                    updateGoalCalled.fulfill()
                }
                $0.widget._reloadAllTimelines = {
                    reloadTimelinesCalled.fulfill()
                }
            }
        )

        await store.send(\.destination.editGoal.delegate.goalUpdated, updatedGoal) {
            $0.weeklyGoal = updatedGoal
            $0.refreshRows()
            $0.destination = nil
        }

        await fulfillment(of: [updateGoalCalled, reloadTimelinesCalled])
    }

    @MainActor
    func testEdiyGoalGoalUpdatedDelegateUpdatesStateAndCacheForMonthlyGoal() async throws {
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

        let updateGoalCalled = expectation(description: "udpateGoal called")

        let store = TestStore(
            initialState: .init(
                monthlyGoal: goal,
                destination: .editGoal(.init(goal: goal))
            ),
            reducer: GoalListFeature.init,
            withDependencies: {
                $0.repository.goals._updateGoal = {
                    XCTAssertEqual($0, updatedGoal)
                    updateGoalCalled.fulfill()
                }
                $0.widget._reloadAllTimelines = {}
            }
        )

        await store.send(\.destination.editGoal.delegate.goalUpdated, updatedGoal) {
            $0.monthlyGoal = updatedGoal
            $0.refreshRows()
            $0.destination = nil
        }

        await fulfillment(of: [updateGoalCalled])
    }

    @MainActor
    func testEdiyGoalGoalUpdatedDelegateUpdatesStateAndCacheForYearlyGoal() async throws {
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

        let updateGoalCalled = expectation(description: "udpateGoal called")

        let store = TestStore(
            initialState: .init(
                yearlyGoal: goal,
                destination: .editGoal(.init(goal: goal))
            ),
            reducer: GoalListFeature.init,
            withDependencies: {
                $0.repository.goals._updateGoal = {
                    XCTAssertEqual($0, updatedGoal)
                    updateGoalCalled.fulfill()
                }
                $0.widget._reloadAllTimelines = {}
            }
        )

        await store.send(\.destination.editGoal.delegate.goalUpdated, updatedGoal) {
            $0.yearlyGoal = updatedGoal
            $0.refreshRows()
            $0.destination = nil
        }

        await fulfillment(of: [updateGoalCalled])
    }

    @MainActor
    func testEditGoalGoalClearedDelegateUpdatesStateAndCacheForWeeklyGoal() async throws {
        let goal: Goal = .mock(
            period: .weekly,
            target: .init(value: 1, unit: .kilometers)
        )

        let updatedGoal: Goal = .mock(
            period: .weekly,
            target: nil
        )

        let updateGoalCalled = expectation(description: "udpateGoal called")

        let store = TestStore(
            initialState: .init(
                weeklyGoal: goal,
                destination: .editGoal(.init(goal: goal))
            ),
            reducer: GoalListFeature.init,
            withDependencies: {
                $0.repository.goals._updateGoal = {
                    XCTAssertEqual($0, updatedGoal)
                    updateGoalCalled.fulfill()
                }
                $0.widget._reloadAllTimelines = {}
            }
        )

        await store.send(\.destination.editGoal.delegate.goalCleared, .weekly) {
            $0.weeklyGoal = updatedGoal
            $0.refreshRows()
            $0.destination = nil
        }

        await fulfillment(of: [updateGoalCalled])
    }

    @MainActor
    func testEdiyGoalGoalClearedDelegateUpdatesStateAndCacheForMonthlyGoal() async throws {
        let goal: Goal = .mock(
            period: .monthly,
            target: .init(value: 1, unit: .kilometers)
        )

        let updatedGoal: Goal = .mock(
            period: .monthly,
            target: nil
        )

        let updateGoalCalled = expectation(description: "udpateGoal called")

        let store = TestStore(
            initialState: .init(
                monthlyGoal: goal,
                destination: .editGoal(.init(goal: goal))
            ),
            reducer: GoalListFeature.init,
            withDependencies: {
                $0.repository.goals._updateGoal = {
                    XCTAssertEqual($0, updatedGoal)
                    updateGoalCalled.fulfill()
                }
                $0.widget._reloadAllTimelines = {}
            }
        )

        await store.send(\.destination.editGoal.delegate.goalCleared, .monthly) {
            $0.monthlyGoal = updatedGoal
            $0.refreshRows()
            $0.destination = nil
        }

        await fulfillment(of: [updateGoalCalled])
    }

    @MainActor
    func testEdiyGoalGoalClearedDelegateUpdatesStateAndCacheForYearlyGoal() async throws {
        let goal: Goal = .mock(
            period: .yearly,
            target: .init(value: 1, unit: .kilometers)
        )

        let updatedGoal: Goal = .mock(
            period: .yearly,
            target: nil
        )

        let updateGoalCalled = expectation(description: "udpateGoal called")
        let reloadTimelinesCalled = expectation(description: "reload timelines called")

        let store = TestStore(
            initialState: .init(
                yearlyGoal: goal,
                destination: .editGoal(.init(goal: goal))
            ),
            reducer: GoalListFeature.init,
            withDependencies: {
                $0.repository.goals._updateGoal = {
                    XCTAssertEqual($0, updatedGoal)
                    updateGoalCalled.fulfill()
                }
                $0.widget._reloadAllTimelines = {
                    reloadTimelinesCalled.fulfill()
                }
            }
        )

        await store.send(\.destination.editGoal.delegate.goalCleared, .yearly) {
            $0.yearlyGoal = updatedGoal
            $0.refreshRows()
            $0.destination = nil
        }

        await fulfillment(of: [updateGoalCalled, reloadTimelinesCalled])
    }

    @MainActor
    func testDeepLinkHandling() {
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
        XCTAssertEqual(sut.destination, .detail(.init(goal: weekly)))

        sut.destination = nil

        sut.handleDeepLink(route: .monthly(nil))
        XCTAssertEqual(sut.destination, .detail(.init(goal: monthly)))

        sut.destination = nil

        sut.handleDeepLink(route: .yearly(nil))
        XCTAssertEqual(sut.destination, .detail(.init(goal: yearly)))

        sut.destination = nil

        sut.handleDeepLink(route: .weekly(.edit))
        XCTAssertEqual(sut.destination, .editGoal(.init(goal: weekly)))

        sut.destination = nil

        sut.handleDeepLink(route: .monthly(.edit))
        XCTAssertEqual(sut.destination, .editGoal(.init(goal: monthly)))

        sut.destination = nil

        sut.handleDeepLink(route: .yearly(.edit))
        XCTAssertEqual(sut.destination, .editGoal(.init(goal: yearly)))
    }

    @MainActor
    func testDeepLinkHandlingWhenGoalIsNotFound() {
        var sut: GoalListFeature.State = .init(
            weeklyGoal: nil,
            monthlyGoal: nil,
            yearlyGoal: nil
        )

        sut.handleDeepLink(route: .weekly(nil))
        XCTAssertNil(sut.destination)

        sut.handleDeepLink(route: .monthly(nil))
        XCTAssertNil(sut.destination)

        sut.handleDeepLink(route: .yearly(nil))
        XCTAssertNil(sut.destination)
    }
}
