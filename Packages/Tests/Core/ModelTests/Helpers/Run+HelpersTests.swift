@testable import Model
import Testing
import Foundation

struct Run_HelpersTests {
    @Test func distanceCalculationForCollectionOfRunsIsCorrect() {
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

        #expect(runs.distance == .init(value: sum, unit: .kilometers))
    }
}
