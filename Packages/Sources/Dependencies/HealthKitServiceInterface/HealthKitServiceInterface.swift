import Foundation

public struct HealthKitServiceInterface: Sendable {
    public var permissions: HealthKitPermissions
    public var runningWorkouts: HealthKitRunningWorkouts
    public var support: HealthKitSupport
    public var observation: HealthKitObservation

    public init(
        permissions: HealthKitPermissions,
        runningWorkouts: HealthKitRunningWorkouts,
        support: HealthKitSupport,
        observation: HealthKitObservation
    ) {
        self.permissions = permissions
        self.runningWorkouts = runningWorkouts
        self.support = support
        self.observation = observation
    }
}
