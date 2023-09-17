import Cache
import Dependencies
import HealthKitServiceInterface
import Model
@testable import Repository
import SwiftData
import XCTest

final class RunningWorkouts_LiveTests: XCTestCase {
    func testCachedRunningWorkoutsReturnsNilWhenThereAreNoRuns() {
        let sut: RunningWorkouts = withDependencies {
            $0.swiftData = SwiftDataStack.stack(inMemory: true)
        } operation: {
            .live()
        }

        XCTAssertNil(sut.allRunningWorkouts.cache())
    }

    func testCachedRunningWorkoutsReturnsCorrectRuns() throws {
        let swiftData: SwiftDataStack = .stack(inMemory: true)
        let context = try swiftData.context()

        let cacheRunCount: Int = .random(in: 5 ..< 100)
        let runs: [Cache.Run] = (0 ..< cacheRunCount).map { _ in
            .init(id: .init(), startDate: .now, distance: 0, duration: 0)
        }

        runs.forEach(context.insert)
        try context.save()

        let sut: RunningWorkouts = withDependencies {
            $0.swiftData._context = { context }
        } operation: {
            .live()
        }

        let cachedRuns = try XCTUnwrap(sut.allRunningWorkouts.cache())
        XCTAssertEqual(cachedRuns.count, cacheRunCount)
    }

    func testRemoteRunningWorkoutsReturnsCorrectRunsAndUpdatesCache() async throws {
        let swiftData: SwiftDataStack = .stack(inMemory: true)
        let context = try swiftData.context()

        let healthKitRuns: [MockWorkoutType] = [
            .init(duration: 1, distance: 2),
            .init(duration: 3, distance: 4),
            .init(duration: 5, distance: 6),
            .init(duration: 7, distance: 8),
        ]

        let sut: RunningWorkouts = withDependencies {
            $0.swiftData._context = { context }
            $0.healthKit.runningWorkouts._allRunningWorkouts = { healthKitRuns }
        } operation: {
            .live()
        }

        let remoteRuns = try await sut.allRunningWorkouts.remote()
        XCTAssertEqual(remoteRuns.count, healthKitRuns.count)

        let fetchedRuns = try context.fetchCount(FetchDescriptor<Cache.Run>())
        XCTAssertEqual(fetchedRuns, remoteRuns.count)
    }

    func testFetchingRemoteRunsUpdatesValuesForExistingRun() async throws {
        let swiftData: SwiftDataStack = .stack(inMemory: true)
        let context = try swiftData.context()

        let id: UUID = .init()
        let runs: [Cache.Run] = [
            .init(
                id: id,
                startDate: .now,
                distance: 0,
                duration: 0
            ),
        ]
        runs.forEach(context.insert)
        try context.save()

        let duration: Double = .random(in: 1 ..< 100)
        let distance: Double = .random(in: 1 ..< 100)
        let healthKitRuns: [MockWorkoutType] = [
            .init(
                uuid: id,
                duration: duration,
                distance: distance
            ),
        ]

        let sut: RunningWorkouts = withDependencies {
            $0.swiftData._context = { context }
            $0.healthKit.runningWorkouts._allRunningWorkouts = { healthKitRuns }
        } operation: {
            .live()
        }

        _ = try await sut.allRunningWorkouts.remote()

        let fetchedRuns = try context.fetch(FetchDescriptor<Cache.Run>())
        let updatedRun = try XCTUnwrap(fetchedRuns.first)
        XCTAssertEqual(updatedRun.distance, distance * 1000)
        XCTAssertEqual(updatedRun.duration, duration * 60)
    }

    func testFetchingRemoteRunsDeletesRunsInCacheButNotInResponse() async throws {
        let swiftData: SwiftDataStack = .stack(inMemory: true)
        let context = try swiftData.context()

        let id: UUID = .init()
        let runs: [Cache.Run] = [
            .init(
                id: id,
                startDate: .now,
                distance: 0,
                duration: 0
            ),
            .init(
                id: .init(),
                startDate: .now,
                distance: 0,
                duration: 0
            ),
        ]
        runs.forEach(context.insert)
        try context.save()

        let duration: Double = .random(in: 1 ..< 100)
        let distance: Double = .random(in: 1 ..< 100)
        let healthKitRuns: [MockWorkoutType] = [
            .init(
                uuid: id,
                duration: duration,
                distance: distance
            ),
        ]

        let sut: RunningWorkouts = withDependencies {
            $0.swiftData._context = { context }
            $0.healthKit.runningWorkouts._allRunningWorkouts = { healthKitRuns }
        } operation: {
            .live()
        }

        _ = try await sut.allRunningWorkouts.remote()

        let fetchedRuns = try context.fetch(FetchDescriptor<Cache.Run>())
        XCTAssertEqual(fetchedRuns.count, 1)
    }

    func testRunsWithinGoalReturnsEmptyListWhenNoRunsFound() async throws {
        let swiftData: SwiftDataStack = .stack(inMemory: true)
        let context = try swiftData.context()

        let sut: RunningWorkouts = withDependencies {
            $0.swiftData._context = { context }
            $0.date = .constant(.now)
            $0.calendar = .current
        } operation: {
            .live()
        }

        let goal: Model.Goal = .mock(period: .weekly)
        let remoteRuns = try sut.runs(within: goal)
        XCTAssert(remoteRuns.isEmpty)
    }

    func testRunsWithinGoalReturnsMatchingRunsOnly() throws {
        let swiftData: SwiftDataStack = .stack(inMemory: true)
        let context = try swiftData.context()

        let runs: [Cache.Run] = [
            // before range
            .init(
                id: .init(),
                startDate: .init(timeIntervalSince1970: 0),
                distance: 0,
                duration: 0
            ),
            // inside range
            .init(
                id: .init(),
                startDate: .init(timeIntervalSince1970: 947_073_600),
                distance: 0,
                duration: 0
            ),
            // after range
            .init(
                id: .init(),
                startDate: .now,
                distance: 0,
                duration: 0
            ),
        ]
        runs.forEach(context.insert)
        try context.save()

        let dateForRange: Date = .init(timeIntervalSince1970: 947_246_400)

        let sut: RunningWorkouts = withDependencies {
            $0.swiftData._context = { context }
            $0.date = .constant(dateForRange)
            $0.calendar = .current
        } operation: {
            .live()
        }

        let goal: Model.Goal = .mock(period: .weekly)
        let remoteRuns = try sut.runs(within: goal)
        XCTAssertEqual(remoteRuns.count, 1)
    }
}
