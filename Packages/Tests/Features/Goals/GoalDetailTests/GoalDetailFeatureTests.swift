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
                $0.repository.runningWorkouts._allRunningWorkouts = { .mock(value: []) }
                $0.repository.runningWorkouts._runsWithinGoal = { _, _ in runs }
                $0.uuid = .incrementing
            }
        )

        // setup on appearance
        await store.send(.view(.onAppear)) {
            $0.runs = runs
        }

        await store.receive(\._internal.runsFetched.success)
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
                $0.repository.runningWorkouts._allRunningWorkouts = { .mock(value: []) }
                $0.repository.runningWorkouts._runsWithinGoal = { _, _ in
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
                $0.date = .constant(now)
                $0.repository.runningWorkouts._allRunningWorkouts = { .mock(value: []) }
                $0.repository.runningWorkouts._runsWithinGoal = { _, _ in [] }
                $0.uuid = .constant(.init(1))
            }
        )

        // setup on appearance
        await store.send(.view(.onAppear)) {
            $0.runs = []
            $0.updateEmptyStateRuns(
                calendar: .current,
                date: .constant(now),
                uuid: .constant(.init(1))
            )
        }

        await store.receive(._internal(.runsFetched(.success([]))))
    }

    func testTotalDurationIsCorrectWhenRunsAreNil() {
        let sut: GoalDetailFeature.State = .init(
            goal: .mock(),
            runs: nil
        )

        XCTAssertNil(sut.totalDuration)
    }

    func testTotalDurationIsCorrectWhenRunsAreEmpty() {
        let sut: GoalDetailFeature.State = .init(
            goal: .mock(),
            runs: []
        )

        XCTAssertNil(sut.totalDuration)
    }

    func testTotalDurationIsCorrect() throws {
        let durations: [Double] = [
            .random(in: 1 ..< 100_000),
            .random(in: 1 ..< 100_000),
            .random(in: 1 ..< 100_000),
            .random(in: 1 ..< 100_000),
            .random(in: 1 ..< 100_000),
        ]

        let sut: GoalDetailFeature.State = .init(
            goal: .mock(),
            runs: durations.map { duration in
                .mock(duration: .init(value: duration, unit: .seconds))
            }
        )

        let totalDuration = try XCTUnwrap(sut.totalDuration)
        let expectedTotal = durations.reduce(0, +)
        XCTAssertEqual(totalDuration, .init(value: expectedTotal, unit: .seconds))
    }

    func testAverageDurationIsCorrectWhenRunsAreNil() {
        let sut: GoalDetailFeature.State = .init(
            goal: .mock(),
            runs: nil
        )

        XCTAssertNil(sut.averageDuration)
    }

    func testAverageDurationIsCorrectWhenRunsAreEmpty() {
        let sut: GoalDetailFeature.State = .init(
            goal: .mock(),
            runs: []
        )

        XCTAssertNil(sut.averageDuration)
    }

    func testAverageDurationIsCorrect() throws {
        let durations: [Double] = [
            .random(in: 1 ..< 100_000),
            .random(in: 1 ..< 100_000),
            .random(in: 1 ..< 100_000),
            .random(in: 1 ..< 100_000),
            .random(in: 1 ..< 100_000),
        ]

        let sut: GoalDetailFeature.State = .init(
            goal: .mock(),
            runs: durations.map { duration in
                .mock(duration: .init(value: duration, unit: .seconds))
            }
        )

        let averageDuration = try XCTUnwrap(sut.averageDuration)
        let total = durations.reduce(0, +)
        XCTAssertEqual(averageDuration, .init(value: total / 5, unit: .seconds))
    }

    func testAverageDistanceIsCorrectWhenRunsAreNil() {
        let sut: GoalDetailFeature.State = .init(
            goal: .mock(),
            runs: nil
        )

        XCTAssertNil(sut.averageDistance)
    }

    func testAverageDistanceIsCorrectWhenRunsAreEmpty() {
        let sut: GoalDetailFeature.State = .init(
            goal: .mock(),
            runs: []
        )

        XCTAssertNil(sut.averageDistance)
    }

    func testAverageDistanceIsCorrect() throws {
        let distances: [Double] = [
            .random(in: 1 ..< 100_000),
            .random(in: 1 ..< 100_000),
            .random(in: 1 ..< 100_000),
            .random(in: 1 ..< 100_000),
            .random(in: 1 ..< 100_000),
        ]

        let sut: GoalDetailFeature.State = .init(
            goal: .mock(),
            runs: distances.map { distance in
                .mock(distance: .init(value: distance, unit: .meters))
            }
        )

        let averageDistance = try XCTUnwrap(sut.averageDistance)
        let total = distances.reduce(0, +)
        XCTAssertEqual(averageDistance, .init(value: total / 5, unit: .meters))
    }
}
