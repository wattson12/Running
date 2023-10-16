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
        XCTAssertNil(sut.detail)
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
            detail: .init(
                locations: [
                    .init(
                        latitude: 0,
                        longitude: 0,
                        altitude: .random(in: 1 ..< 1000),
                        timestamp: .now
                    ),
                ],
                distanceSamples: [
                    .init(startDate: .now, distance: 1),
                ]
            )
        )

        context.insert(cached)

        let sut: Model.Run = .init(cached: cached)
        XCTAssertEqual(sut.id, id)
        XCTAssertEqual(sut.startDate, startDate)
        XCTAssertEqual(sut.distance, .init(value: distance, unit: .meters))
        XCTAssertEqual(sut.duration, .init(value: duration, unit: .seconds))

        let detail = try XCTUnwrap(sut.detail)
        XCTAssertEqual(detail.locations.count, 1)
        let location = try XCTUnwrap(detail.locations.first)
        XCTAssertEqual(location.coordinate.latitude, cached.detail?.locations.first?.latitude)
        XCTAssertEqual(location.coordinate.longitude, cached.detail?.locations.first?.longitude)
        XCTAssertEqual(location.altitude.converted(to: .meters).value, cached.detail?.locations.first?.altitude)
        XCTAssertEqual(location.timestamp, cached.detail?.locations.first?.timestamp)

        XCTAssertEqual(detail.distanceSamples.count, 1)
        let sample = try XCTUnwrap(detail.distanceSamples.first)
        XCTAssertEqual(sample.distance.converted(to: .meters).value, cached.detail?.distanceSamples.first?.distance)
        XCTAssertEqual(sample.startDate, cached.detail?.distanceSamples.first?.startDate)
    }
}
