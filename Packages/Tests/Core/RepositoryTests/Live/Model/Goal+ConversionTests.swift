import Cache
import Dependencies
import Model
@testable import Repository
import Testing
import Foundation

@Suite
struct Goal_ConversionTests {
    @Test func conversionFromCacheToModelGoal() throws {
        let target: Double = .random(in: 1 ..< 10000)

        let coreData: CoreDataStack = .stack(inMemory: true)

        try coreData.performWork { context in
            let goal = GoalEntity(context: context)
            goal.period = "monthly"
            goal.target = target

            let sut: Model.Goal = .init(entity: goal)
            #expect(sut.period == .monthly)
            #expect(sut.target == .init(value: target, unit: .meters))
        }
    }
}
