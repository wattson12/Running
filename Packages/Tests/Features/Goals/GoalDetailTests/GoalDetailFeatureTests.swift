import ComposableArchitecture
@testable import GoalDetail
import Model
import Repository
import Testing
import Foundation

@MainActor
@Suite
struct GoalDetailFeatureTests {
    @Test func nonEmptyRunsWithinGoalFlow() async throws {
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
                $0.appStorageKeyFormatWarningEnabled = false
            }
        )

        // setup on appearance
        await store.send(.view(.onAppear)) {
            $0.runs = runs
        }

        await store.receive(\._internal.runsFetched.success)
    }

    @Test func failureWhenFetchingRuns() async throws {
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
                $0.appStorageKeyFormatWarningEnabled = false
            }
        )

        // setup on appearance
        await store.send(.view(.onAppear))

        await store.receive(._internal(.runsFetched(.failure(failure))))
    }

    @Test func emptyRunsWithinGoalFlow() async throws {
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
                $0.appStorageKeyFormatWarningEnabled = false
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

    @Test func totalDurationIsCorrectWhenRunsAreNil() {
        let sut: GoalDetailFeature.State = .init(
            goal: .mock(),
            runs: nil
        )

        #expect(sut.totalDuration == nil)
    }

    @Test func totalDurationIsCorrectWhenRunsAreEmpty() {
        let sut: GoalDetailFeature.State = .init(
            goal: .mock(),
            runs: []
        )

        #expect(sut.totalDuration == nil)
    }

    @Test func totalDurationIsCorrect() throws {
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

        let totalDuration = try #require(sut.totalDuration)
        let expectedTotal = durations.reduce(0, +)
        #expect(totalDuration == .init(value: expectedTotal, unit: .seconds))
    }

    @Test func averageDurationIsCorrectWhenRunsAreNil() {
        let sut: GoalDetailFeature.State = .init(
            goal: .mock(),
            runs: nil
        )

        #expect(sut.averageDuration == nil)
    }

    @Test func averageDurationIsCorrectWhenRunsAreEmpty() {
        let sut: GoalDetailFeature.State = .init(
            goal: .mock(),
            runs: []
        )

        #expect(sut.averageDuration == nil)
    }

    @Test func averageDurationIsCorrect() throws {
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

        let averageDuration = try #require(sut.averageDuration)
        let total = durations.reduce(0, +)
        #expect(averageDuration == .init(value: total / 5, unit: .seconds))
    }

    @Test func averageDistanceIsCorrectWhenRunsAreNil() {
        let sut: GoalDetailFeature.State = .init(
            goal: .mock(),
            runs: nil
        )

        #expect(sut.averageDistance == nil)
    }

    @Test func averageDistanceIsCorrectWhenRunsAreEmpty() {
        let sut: GoalDetailFeature.State = .init(
            goal: .mock(),
            runs: []
        )

        #expect(sut.averageDistance == nil)
    }

    @Test func averageDistanceIsCorrect() throws {
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

        let averageDistance = try #require(sut.averageDistance)
        let total = distances.reduce(0, +)
        #expect(averageDistance == .init(value: total / 5, unit: .meters))
    }
}
