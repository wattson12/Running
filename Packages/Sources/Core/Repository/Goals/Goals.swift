import DependenciesMacros
import Foundation
import Model

@DependencyClient
public struct Goals: Sendable {
    public var _goal: @Sendable (Goal.Period) throws -> Goal
    public var _updateGoal: @Sendable (Goal) throws -> Void

    public init(
        goal: @escaping @Sendable (Goal.Period) throws -> Goal,
        updateGoal: @escaping @Sendable (Goal) throws -> Void
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
