@testable import Model
import XCTest

final class Run_HelpersTests: XCTestCase {
    func testDistanceCalculationForCollectionOfRunsIsCorrect() {
        let distances: [Double] = [
            .random(in: 1 ..< 10000),
            .random(in: 1 ..< 10000),
            .random(in: 1 ..< 10000),
            .random(in: 1 ..< 10000),
            .random(in: 1 ..< 10000),
            .random(in: 1 ..< 10000),
            .random(in: 1 ..< 10000),
            .random(in: 1 ..< 10000),
            .random(in: 1 ..< 10000),
            .random(in: 1 ..< 10000),
        ]

        var sum: Double = 0
        for distance in distances {
            sum += distance
        }

        let runs: [Run] = distances.map {
            .mock(distance: .init(value: $0, unit: .kilometers))
        }

        XCTAssertEqual(runs.distance, .init(value: sum, unit: .kilometers))
    }
}
