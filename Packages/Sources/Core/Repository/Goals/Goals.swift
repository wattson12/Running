import Foundation
import Model

public struct Goals {
    public var _goal: (Goal.Period) throws -> Goal
    public var _updateGoal: (Goal) throws -> Void

    public init(
        goal: @escaping (Goal.Period) throws -> Goal,
        updateGoal: @escaping (Goal) throws -> Void
    ) {
        _goal = goal
        _updateGoal = updateGoal
    }
}

public extension Goals {
    func goal(in period: Goal.Period) throws -> Goal {
        try _goal(period)
    }

    func update(goal: Goal) throws {
        try _updateGoal(goal)
    }
}
