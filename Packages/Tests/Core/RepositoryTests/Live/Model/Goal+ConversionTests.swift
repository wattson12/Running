import Cache
import Dependencies
import Model
@testable import Repository
import XCTest

final class Goal_ConversionTests: XCTestCase {
    func testConversionFromCacheToModelGoal() throws {
        let target: Double = .random(in: 1 ..< 10000)

        let coreData: CoreDataStack = .stack(inMemory: true)

        try coreData.performWork { context in
            let goal = GoalEntity(context: context)
            goal.period = "monthly"
            goal.target = target

            let sut: Model.Goal = .init(entity: goal)
            XCTAssertEqual(sut.period, .monthly)
            XCTAssertEqual(sut.target, .init(value: target, unit: .meters))
        }
    }
}
