import Foundation

public struct RepositoryInterface {
    public var goals: Goals
    public var permissions: Permissions
    public var runningWorkouts: RunningWorkouts
    public var support: Support

    public init(
        goals: Goals,
        permissions: Permissions,
        runningWorkouts: RunningWorkouts,
        support: Support
    ) {
        self.goals = goals
        self.permissions = permissions
        self.runningWorkouts = runningWorkouts
        self.support = support
    }
}
