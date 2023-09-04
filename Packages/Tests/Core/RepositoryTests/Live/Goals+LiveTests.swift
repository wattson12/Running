import Cache
import Dependencies
import Model
@testable import Repository
import SwiftData
import XCTest

final class Goals_LiveTests: XCTestCase {
    func testGoalInPeriodWhenGoalDoesNotExist() throws {
        let swiftData: SwiftDataStack = .stack(inMemory: true)
        let context = try swiftData.context()
        try context.delete(model: Cache.Goal.self)

        let sut: Goals = withDependencies {
            $0.swiftData = swiftData
        } operation: {
            .live()
        }

        let goal = try sut.goal(in: .weekly)
        XCTAssertEqual(goal.period, .weekly)
        XCTAssertNil(goal.target)
    }

    func testGoalInPeriodWhenGoalExists() throws {
        let swiftData: SwiftDataStack = .stack(inMemory: true)
        let context = try swiftData.context()

        let target: Double = .random(in: 1 ..< 10000)
        let existingGoal = Cache.Goal.create(period: "weekly", target: target)
        context.insert(existingGoal)
        try context.save()

        let sut: Goals = withDependencies {
            $0.swiftData._context = { context }
        } operation: {
            .live()
        }

        let goal = try sut.goal(in: .weekly)
        XCTAssertEqual(goal.period, .weekly)
        XCTAssertEqual(goal.target, .init(value: target, unit: .meters))
    }

    func testUpdateGoalSetsNewTargetValueCorrectly() throws {
        let swiftData: SwiftDataStack = .stack(inMemory: true)
        let context = try swiftData.context()

        let originalTarget: Double = .random(in: 1 ..< 10000)
        let existingGoal = Cache.Goal.create(period: "weekly", target: originalTarget)
        context.insert(existingGoal)
        try context.save()

        let sut: Goals = withDependencies {
            $0.swiftData._context = { context }
        } operation: {
            .live()
        }

        let newTarget: Double = .random(in: 1 ..< 10000)
        let updatedGoal: Model.Goal = .mock(
            period: .weekly,
            target: .init(value: newTarget, unit: .meters)
        )

        try sut.update(goal: updatedGoal)

        let modifiedGoal = try sut.goal(in: .weekly)
        XCTAssertEqual(modifiedGoal.target, updatedGoal.target)
    }
}
