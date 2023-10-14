import Cache
import HealthKit
import HealthKitServiceInterface
import Model
@testable import Repository
import XCTest

final class Run_ConversionTests: XCTestCase {
    func testRunIsNilWhenWorkoutContainsNoDistanceStatistics() {
        let workout = MockWorkoutType(
            uuid: .init(),
            startDate: .init(timeIntervalSince1970: .random(in: 1 ..< 1_000_000)),
            duration: .random(in: 1 ..< 10000),
            allStatistics: [:]
        )

        let sut: Model.Run? = .init(model: workout)
        XCTAssertNil(sut)
    }

    func testRunIsNilWhenWorkoutDistanceStatisticsHasNoSumQuantity() {
        let workout = MockWorkoutType(
            uuid: .init(),
            startDate: .init(timeIntervalSince1970: .random(in: 1 ..< 1_000_000)),
            duration: .random(in: 1 ..< 10000),
            allStatistics: [
                .init(.distanceWalkingRunning): MockStatisticsType(quantity: nil),
            ]
        )

        let sut: Model.Run? = .init(model: workout)
        XCTAssertNil(sut)
    }

    func testRunIsCreatedCorrectlyFromModelWithDistanceQuantity() throws {
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

        let sut: Model.Run = try XCTUnwrap(.init(model: workout))
        XCTAssertEqual(sut.id, workout.uuid)
        XCTAssertEqual(sut.startDate, workout.startDate)
        XCTAssertEqual(sut.distance, .init(value: meters, unit: .meters))
        XCTAssertEqual(sut.duration, .init(value: workout.duration, unit: .seconds))
        XCTAssert(sut.locations.isEmpty)
        XCTAssert(sut.distanceSamples.isEmpty)
    }

    func testConversionFromCachedRun() throws {
        let id: UUID = .init()
        let startDate: Date = .init(timeIntervalSince1970: .random(in: 1 ..< 1_000_000))
        let distance: Double = .random(in: 1 ..< 10000)
        let duration: Double = .random(in: 1 ..< 10000)

        let swiftData: SwiftDataStack = .stack(inMemory: true)
        let context = try swiftData.context()
        let cached: Cache.Run = .init(
            id: id,
            startDate: startDate,
            distance: distance,
            duration: duration,
            locations: [
                .init(
                    coordinate: .init(
                        latitude: .random(in: -90 ... 90),
                        longitude: .random(in: -90 ... 90)
                    ),
                    altitude: .random(in: 1 ..< 1000),
                    timestamp: .now
                ),
            ],
            distanceSamples: [
                .init(
                    startDate: .now,
                    distance: .random(in: 1 ..< 1000)
                ),
            ]
        )
        context.insert(cached)

        let sut: Model.Run = .init(cached: cached)
        XCTAssertEqual(sut.id, id)
        XCTAssertEqual(sut.startDate, startDate)
        XCTAssertEqual(sut.distance, .init(value: distance, unit: .meters))
        XCTAssertEqual(sut.duration, .init(value: duration, unit: .seconds))

        XCTAssertEqual(sut.locations.count, 1)
        let location = try XCTUnwrap(sut.locations.first)
        XCTAssertEqual(location.coordinate.latitude, cached.locations.first?.coordinate.latitude)
        XCTAssertEqual(location.coordinate.longitude, cached.locations.first?.coordinate.longitude)
        XCTAssertEqual(location.altitude.converted(to: .meters).value, cached.locations.first?.altitude)
        XCTAssertEqual(location.timestamp, cached.locations.first?.timestamp)

        XCTAssertEqual(sut.distanceSamples.count, 1)
        let sample = try XCTUnwrap(sut.distanceSamples.first)
        XCTAssertEqual(sample.distance.converted(to: .meters).value, cached.distanceSamples.first?.distance)
        XCTAssertEqual(sample.startDate, cached.distanceSamples.first?.startDate)
    }
}
