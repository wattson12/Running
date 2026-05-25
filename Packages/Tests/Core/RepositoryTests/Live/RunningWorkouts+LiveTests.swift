import Cache
import CoreLocation
import Dependencies
import HealthKit
import HealthKitServiceInterface
import Model
@testable import Repository
import Testing
import Foundation

@MainActor
struct RunningWorkouts_LiveTests {
    @MainActor
    func testCachedRunningWorkoutsReturnsNilWhenThereAreNoRuns() {
        let sut: RunningWorkouts = withDependencies {
            $0.coreData = .stack(inMemory: true)
        } operation: {
            .live()
        }

        #expect(sut.allRunningWorkouts.cache() == nil)
    }

    @MainActor
    func testCachedRunningWorkoutsReturnsCorrectRuns() throws {
        let coreData: CoreDataStack = .stack(inMemory: true)

        let cacheRunCount: Int = .random(in: 5 ..< 100)

        try coreData.performWork { context in
            for _ in 0 ..< cacheRunCount {
                let newRun = Cache.RunEntity(context: context)
                newRun.id = .init()
                newRun.startDate = .now
                newRun.distance = 0
                newRun.duration = 0
                newRun.detail = nil
            }

            try context.save()
        }

        let sut: RunningWorkouts = withDependencies {
            $0.coreData = coreData
        } operation: {
            .live()
        }

        let cachedRuns = try #require(sut.allRunningWorkouts.cache())
        #expect(cachedRuns.count == cacheRunCount)
    }

    @MainActor
    func testRemoteRunningWorkoutsReturnsCorrectRunsAndUpdatesCache() async throws {
        let coreData: CoreDataStack = .stack(inMemory: true)

        let healthKitRuns: [MockWorkoutType] = [
            .init(duration: 1, distance: 2),
            .init(duration: 3, distance: 4),
            .init(duration: 5, distance: 6),
            .init(duration: 7, distance: 8),
        ]

        let sut: RunningWorkouts = withDependencies {
            $0.coreData = coreData
            $0.healthKit.runningWorkouts._allRunningWorkouts = { healthKitRuns }
        } operation: {
            .live()
        }

        let remoteRuns = try await sut.allRunningWorkouts.remote()
        #expect(remoteRuns.count == healthKitRuns.count)

        let fetchedRuns = try coreData.performWork { context in
            let fetchRequest = Cache.RunEntity.makeFetchRequest()
            return try context.count(for: fetchRequest)
        }
        #expect(fetchedRuns == remoteRuns.count)
    }

    @MainActor
    func testFetchingRemoteRunsUpdatesValuesForExistingRun() async throws {
        let coreData: CoreDataStack = .stack(inMemory: true)

        let id: UUID = .init()
        try coreData.performWork { context in
            let run = Cache.RunEntity(context: context)
            run.id = id
            run.startDate = .now
            run.distance = 0
            run.duration = 0

            let location = Cache.LocationEntity(context: context)
            location.altitude = .random(in: 1 ..< 10000)
            location.latitude = .random(in: -90 ... 90)
            location.longitude = .random(in: -90 ... 90)
            location.timestamp = .now

            let distanceSample = Cache.DistanceSampleEntity(context: context)
            distanceSample.startDate = .now
            distanceSample.distance = .random(in: 1 ..< 10)

            let runDetail = Cache.RunDetailEntity(context: context)
            runDetail.locations = [location]
            runDetail.distanceSamples = [distanceSample]
            run.detail = runDetail
        }

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
            $0.coreData = coreData
            $0.healthKit.runningWorkouts._allRunningWorkouts = { healthKitRuns }
        } operation: {
            .live()
        }

        let allRuns = try await sut.allRunningWorkouts.remote()

        try coreData.performWork { context in
            let fetchedRuns = try context.fetch(Cache.RunEntity.makeFetchRequest())

            let updatedRun = try #require(fetchedRuns.first)
            #expect(updatedRun.distance == distance * 1000)
            #expect(updatedRun.duration == duration * 60)

            let firstRun = try #require(allRuns.first)
            #expect(firstRun.detail == nil)
        }
    }

    @MainActor
    func testFetchingRemoteRunsDeletesRunsInCacheButNotInResponse() async throws {
        let coreData: CoreDataStack = .stack(inMemory: true)

        let id: UUID = .init()
        try coreData.performWork { context in
            let matchingRun = Cache.RunEntity(context: context)
            matchingRun.id = id
            matchingRun.startDate = .now
            matchingRun.distance = 0
            matchingRun.duration = 0
            matchingRun.detail = nil

            let nonMatchingRun = Cache.RunEntity(context: context)
            nonMatchingRun.id = .init()
            nonMatchingRun.startDate = .now
            nonMatchingRun.distance = 0
            nonMatchingRun.duration = 0
            nonMatchingRun.detail = nil

            try context.save()
        }

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
            $0.coreData = coreData
            $0.healthKit.runningWorkouts._allRunningWorkouts = { healthKitRuns }
        } operation: {
            .live()
        }

        _ = try await sut.allRunningWorkouts.remote()

        let fetchedRunsCount = try coreData.performWork { context in
            try context.count(for: Cache.RunEntity.makeFetchRequest())
        }
        #expect(fetchedRunsCount == 1)
    }

    @MainActor
    func testRunsWithinGoalReturnsEmptyListWhenNoRunsFound() async throws {
        let coreData: CoreDataStack = .stack(inMemory: true)

        let sut: RunningWorkouts = withDependencies {
            $0.coreData = coreData
            $0.date = .constant(.now)
            $0.calendar = .current
        } operation: {
            .live()
        }

        let goal: Model.Goal = .mock(period: .weekly)
        let remoteRuns = try withDependencies {
            $0.date = .constant(.now)
        } operation: {
            try sut.runs(within: goal)
        }
        #expect(remoteRuns.isEmpty == true)
    }

    @MainActor
    func testRunsWithinGoalReturnsMatchingRunsOnly() throws {
        let coreData: CoreDataStack = .stack(inMemory: true)

        try coreData.performWork { context in
            // before range
            let beforeRange = RunEntity(context: context)
            beforeRange.id = .init()
            beforeRange.startDate = .init(timeIntervalSince1970: 0)
            beforeRange.distance = 0
            beforeRange.duration = 0
            beforeRange.detail = nil

            // inside range
            let insideRange = RunEntity(context: context)
            insideRange.id = .init()
            insideRange.startDate = .init(timeIntervalSince1970: 947_073_600)
            insideRange.distance = 0
            insideRange.duration = 0
            insideRange.detail = nil

            let afterRange = RunEntity(context: context)
            afterRange.id = .init()
            afterRange.startDate = .now
            afterRange.distance = 0
            afterRange.duration = 0
            afterRange.detail = nil

            try context.save()
        }

        let dateForRange: Date = .init(timeIntervalSince1970: 947_246_400)

        let sut: RunningWorkouts = withDependencies {
            $0.coreData = coreData
            $0.date = .constant(dateForRange)
            $0.calendar = .current
        } operation: {
            .live()
        }

        let goal: Model.Goal = .mock(period: .weekly)
        let remoteRuns = try withDependencies {
            $0.date = .constant(.now)
        } operation: {
            try sut.runs(within: goal)
        }
        #expect(remoteRuns.count == 1)
    }

    @MainActor
    func testRunDetailThrowsHealthKitErrorWhenDetailFails() async throws {
        let healthKitError = NSError(domain: #fileID, code: #line)

        let sut: RunningWorkouts = withDependencies {
            $0.healthKit.runningWorkouts._detail = { _ in throw healthKitError }
        } operation: {
            .live()
        }

        do {
            let detail = try await sut.detail(for: .init())
            XCTFail("Unexpected success: \(detail)")
        } catch {
            #expect(error as NSError == healthKitError)
        }
    }

    @MainActor
    func testRunDetailThrowsCorrectErrorWhenRunDoesntExistInCache() async throws {
        let sut: RunningWorkouts = withDependencies {
            $0.coreData = .stack(inMemory: true)
            $0.healthKit.runningWorkouts._detail = { _ in
                .init(
                    locations: [],
                    samples: []
                )
            }
        } operation: {
            .live()
        }

        do {
            let detail = try await sut.detail(for: .init())
            XCTFail("Unexpected success: \(detail)")
        } catch {}
    }

    @MainActor
    func testRemoteDetailsAreUpdatedOnExistingCacheValue() async throws {
        let coreData: CoreDataStack = .stack(inMemory: true)
        let id: UUID = .init()
        try coreData.performWork { context in
            let run = Cache.RunEntity(context: context)
            run.id = id
            run.startDate = .now
            run.distance = 0
            run.duration = 0
            run.detail = nil
        }

        let locations: [CLLocation] = [
            .init(
                coordinate: .init(
                    latitude: .random(in: -90 ... 90),
                    longitude: .random(in: -90 ... 90)
                ),
                altitude: .random(in: 1 ..< 1000),
                horizontalAccuracy: 1,
                verticalAccuracy: 1,
                timestamp: .now
            ),
        ]
        let samples: [HKCumulativeQuantitySample] = [
            .init(type: .init(.distanceWalkingRunning), quantity: .init(unit: .meter(), doubleValue: .random(in: 1 ..< 100)), start: .now, end: .now.addingTimeInterval(1)),
        ]

        let remoteDetail: WorkoutDetail = .init(
            locations: locations,
            samples: samples
        )

        let sut: RunningWorkouts = withDependencies {
            $0.coreData = coreData
            $0.healthKit.runningWorkouts._detail = { _ in remoteDetail }
        } operation: {
            .live()
        }

        let run = try await sut.detail(for: id)

        #expect(run.detail?.locations.count == 1)
        #expect(run.detail?.locations.first?.coordinate.latitude == locations.first?.coordinate.latitude)
        #expect(run.detail?.locations.first?.coordinate.longitude == locations.first?.coordinate.longitude)
        #expect(run.detail?.locations.first?.altitude.converted(to: .meters).value == locations.first?.altitude)
        #expect(run.detail?.locations.first?.timestamp == locations.first?.timestamp)

        #expect(run.detail?.distanceSamples.count == 1)
        #expect(run.detail?.distanceSamples.first?.distance.converted(to: .meters).value == samples.first?.sumQuantity.doubleValue(for: .meter()))
        #expect(run.detail?.distanceSamples.first?.startDate == samples.first?.startDate)
    }

    @MainActor
    func testRemoteDetailsAreSavedToContext() async throws {
        let coreData: CoreDataStack = .stack(inMemory: true)

        let id: UUID = .init()
        try coreData.performWork { context in
            let run = Cache.RunEntity(context: context)
            run.id = id
            run.startDate = .now
            run.distance = 0
            run.duration = 0
            run.detail = nil
        }

        let locationCount: Int = .random(in: 1 ..< 1000)
        let locations: [CLLocation] = (0 ..< locationCount).map { _ in
            .init(
                coordinate: .init(
                    latitude: .random(in: -90 ... 90),
                    longitude: .random(in: -90 ... 90)
                ),
                altitude: .random(in: 1 ..< 1000),
                horizontalAccuracy: 1,
                verticalAccuracy: 1,
                timestamp: .now
            )
        }
        let sampleCount: Int = .random(in: 1 ..< 1000)
        let samples: [HKCumulativeQuantitySample] = (0 ..< sampleCount).map { _ in
            .init(
                type: .init(.distanceWalkingRunning),
                quantity: .init(
                    unit: .meter(),
                    doubleValue: .random(in: 1 ..< 100)
                ),
                start: .now,
                end: .now.addingTimeInterval(1)
            )
        }

        let remoteDetail: WorkoutDetail = .init(
            locations: locations,
            samples: samples
        )

        let sut: RunningWorkouts = withDependencies {
            $0.coreData = coreData
            $0.healthKit.runningWorkouts._detail = { _ in remoteDetail }
        } operation: {
            .live()
        }

        let _ = try await sut.detail(for: id)

        try coreData.performWork { context in
            let fetchRequest = RunEntity.makeFetchRequest()
            fetchRequest.predicate = .init(format: "id == %@", id.uuidString)

            let savedRuns = try context.fetch(fetchRequest)

            let savedRun = try #require(savedRuns.first)
            #expect(savedRun.detail?.locations.count == locationCount)
            #expect(savedRun.detail?.distanceSamples.count == sampleCount)
        }
    }
}
