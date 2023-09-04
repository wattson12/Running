import ComposableArchitecture
@testable import GoalDetail
import Model
import Repository
import XCTest

@MainActor
final class GoalDetailFeatureTests: XCTestCase {
    func testNonEmptyRunsWithinGoalFlow() async throws {
        let now: Date = .init(timeIntervalSince1970: 1_000_000)

        let runs: [Run] = [
            .mock(),
            .mock(),
            .mock(),
            .mock(),
            .mock(),
        ]

        let store = TestStore(
            initialState: .init(
                goal: .mock(
                    period: .weekly,
                    target: .init(value: 100, unit: .kilometers)
                )
            ),
            reducer: GoalDetailFeature.init,
            withDependencies: {
                $0.calendar = .current
                $0.date = .constant(now)
                $0.repository.runningWorkouts._runsWithinGoal = { _ in runs }
                $0.uuid = .incrementing
            }
        )

        // setup on appearance
        await store.send(.view(.onAppear)) {
            $0.runs = runs
        }

        await store.receive(._internal(.runsFetched(.success(runs))))
    }

    func testFailureWhenFetchingRuns() async throws {
        let now: Date = .init(timeIntervalSince1970: 1_000_000)

        let failure = NSError(domain: #fileID, code: #line)
        let store = TestStore(
            initialState: .init(
                goal: .mock(
                    period: .weekly,
                    target: .init(value: 100, unit: .kilometers)
                )
            ),
            reducer: GoalDetailFeature.init,
            withDependencies: {
                $0.calendar = .current
                $0.date = .constant(now)
                $0.repository.runningWorkouts._runsWithinGoal = { _ in
                    throw failure
                }
                $0.uuid = .incrementing
            }
        )

        // setup on appearance
        await store.send(.view(.onAppear))

        await store.receive(._internal(.runsFetched(.failure(failure))))
    }

    func testEmptyRunsWithinGoalFlow() async throws {
        let now: Date = .init(timeIntervalSince1970: 1_000_000)

        let store = TestStore(
            initialState: .init(
                goal: .mock(
                    period: .weekly,
                    target: .init(value: 100, unit: .kilometers)
                )
            ),
            reducer: GoalDetailFeature.init,
            withDependencies: {
                $0.calendar = .current
                $0.calendar.timeZone = .init(secondsFromGMT: 0)!
                $0.date = .constant(now)
                $0.repository.runningWorkouts._runsWithinGoal = { _ in [] }
                $0.uuid = .incrementing
            }
        )

        // setup on appearance
        await store.send(.view(.onAppear)) {
            $0.runs = []
            $0.emptyStateRuns = [
                .mock(
                    id: .init(0),
                    startDate: .init(timeIntervalSince1970: 864_000),
                    distance: .init(value: 40, unit: .kilometers),
                    duration: .init(value: 200, unit: .minutes)
                ),
                .mock(
                    id: .init(1),
                    startDate: .init(timeIntervalSince1970: 1_036_800),
                    distance: .init(value: 40, unit: .kilometers),
                    duration: .init(value: 200, unit: .minutes)
                ),
                .mock(
                    id: .init(2),
                    startDate: .init(timeIntervalSince1970: 1_209_600),
                    distance: .init(value: 40, unit: .kilometers),
                    duration: .init(value: 200, unit: .minutes)
                ),
            ]
        }

        await store.receive(._internal(.runsFetched(.success([]))))
    }
}
