import Cache
import HealthKit
import HealthKitServiceInterface
import Model
@testable import Repository
import Testing
import Foundation

@Suite
struct Run_ConversionTests {
    @Test func runIsNilWhenWorkoutContainsNoDistanceStatistics() {
        let workout = MockWorkoutType(
            uuid: .init(),
            startDate: .init(timeIntervalSince1970: .random(in: 1 ..< 1_000_000)),
            duration: .random(in: 1 ..< 10000),
            allStatistics: [:]
        )

        let sut: Model.Run? = .init(model: workout)
        #expect(sut == nil)
    }

    @Test func runIsNilWhenWorkoutDistanceStatisticsHasNoSumQuantity() {
        let workout = MockWorkoutType(
            uuid: .init(),
            startDate: .init(timeIntervalSince1970: .random(in: 1 ..< 1_000_000)),
            duration: .random(in: 1 ..< 10000),
            allStatistics: [
                .init(.distanceWalkingRunning): MockStatisticsType(quantity: nil),
            ]
        )

        let sut: Model.Run? = .init(model: workout)
        #expect(sut == nil)
    }

    @Test func runIsCreatedCorrectlyFromModelWithDistanceQuantity() throws {
        let meters: Double = .random(in: 1 ..< 10000)
        let quantity: HKQuantity = .init(unit: .meter(), doubleValue: meters)

        let workout = MockWorkoutType(
            uuid: .init(),
            startDate: .init(timeIntervalSince1970: .random(in: 1 ..< 1_000_000)),
            duration: .random(in: 1 ..< 10000),
            allStatistics: [
                .init(.distanceWalkingRunning): MockStatisticsType(quantity: quantity),
            ]
        )

        let sut: Model.Run = try #require(.init(model: workout))
        #expect(sut.id == workout.uuid)
        #expect(sut.startDate == workout.startDate)
        #expect(sut.distance == .init(value: meters, unit: .meters))
        #expect(sut.duration == .init(value: workout.duration, unit: .seconds))
    }

    @Test func conversionFromCachedRun() throws {
        let id: UUID = .init()
        let startDate: Date = .init(timeIntervalSince1970: .random(in: 1 ..< 1_000_000))
        let distance: Double = .random(in: 1 ..< 10000)
        let duration: Double = .random(in: 1 ..< 10000)

        let coreData: CoreDataStack = .stack(inMemory: true)

        try coreData.performWork { context in
            let cached = RunEntity(context: context)
            cached.id = id
            cached.startDate = startDate
            cached.distance = distance
            cached.duration = duration

            let locationEntity = LocationEntity(context: context)
            locationEntity.latitude = 0
            locationEntity.longitude = 0
            locationEntity.altitude = .random(in: 1 ..< 1000)
            locationEntity.timestamp = .now

            let distanceSample = DistanceSampleEntity(context: context)
            distanceSample.startDate = .now
            distanceSample.distance = 1

            let runDetail = RunDetailEntity(context: context)
            runDetail.locations = Set([locationEntity])
            runDetail.distanceSamples = Set([distanceSample])

            cached.detail = runDetail

            let sut: Model.Run = .init(entity: cached, includeDetail: true)
            #expect(sut.id == id)
            #expect(sut.startDate == startDate)
            #expect(sut.distance == .init(value: distance, unit: .meters))
            #expect(sut.duration == .init(value: duration, unit: .seconds))

            let detail = try #require(sut.detail)
            #expect(detail.locations.count == 1)
            let location = try #require(detail.locations.first)
            #expect(location.coordinate.latitude == cached.detail?.locations.first?.latitude)
            #expect(location.coordinate.longitude == cached.detail?.locations.first?.longitude)
            #expect(location.altitude.converted(to: .meters).value == cached.detail?.locations.first?.altitude)
            #expect(location.timestamp == cached.detail?.locations.first?.timestamp)

            #expect(detail.distanceSamples.count == 1)
            let sample = try #require(detail.distanceSamples.first)
            #expect(sample.distance.converted(to: .meters).value == cached.detail?.distanceSamples.first?.distance)
            #expect(sample.startDate == cached.detail?.distanceSamples.first?.startDate)
        }
    }
}
