import Cache
import Dependencies
import Model
@testable import Repository
import XCTest

final class Goal_ConversionTests: XCTestCase {
    func testConversionFromCacheToModelGoal() throws {
        let target: Double = .random(in: 1 ..< 10000)

        let swiftData: SwiftDataStack = .stack(inMemory: true)
        let context = try swiftData.context()
        let cached: Cache.Goal = .create(period: "monthly", target: target)
        context.insert(cached)

        let sut: Model.Goal = .init(cached: cached)
        XCTAssertEqual(sut.period, .monthly)
        XCTAssertEqual(sut.target, .init(value: target, unit: .meters))
    }
}
