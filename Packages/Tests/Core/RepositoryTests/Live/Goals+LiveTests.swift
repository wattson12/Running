import Cache
import Dependencies
import Model
@testable import Repository
import SwiftData
import Testing
import Foundation

@Suite
struct Goals_LiveTests {
    @Test func goalInPeriodWhenGoalDoesNotExist() throws {
        let coreData: CoreDataStack = .stack(inMemory: true)

        let sut: Goals = withDependencies {
            $0.coreData = coreData
        } operation: {
            .live()
        }

        let goal = try sut.goal(in: .weekly)
        #expect(goal.period == .weekly)
        #expect(goal.target == nil)
    }

    @Test func goalInPeriodWhenGoalExists() throws {
        let coreData: CoreDataStack = .stack(inMemory: true)

        let target: Double = .random(in: 1 ..< 10000)

        try coreData.performWork { context in
            let existingGoal = Cache.GoalEntity(context: context)
            existingGoal.period = "weekly"
            existingGoal.target = target
            try context.save()
        }

        let sut: Goals = withDependencies {
            $0.coreData = coreData
        } operation: {
            .live()
        }

        let goal = try sut.goal(in: .weekly)
        #expect(goal.period == .weekly)
        #expect(goal.target == .init(value: target, unit: .meters))
    }

    @Test func updateGoalSetsNewTargetValueCorrectly() throws {
        let coreData: CoreDataStack = .stack(inMemory: true)

        try coreData.performWork { context in
            let originalTarget: Double = .random(in: 1 ..< 10000)
            let existingGoal = Cache.GoalEntity(context: context)
            existingGoal.period = "weekly"
            existingGoal.target = originalTarget
            try context.save()
        }

        let sut: Goals = withDependencies {
            $0.coreData = coreData
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
        #expect(modifiedGoal.target == updatedGoal.target)
    }
}
