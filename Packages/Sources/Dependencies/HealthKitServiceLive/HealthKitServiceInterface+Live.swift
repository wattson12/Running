import Dependencies
import Foundation
import HealthKitServiceInterface

extension HealthKitServiceInterfaceDependencyKey: DependencyKey {
    public static var liveValue: HealthKitServiceInterface = .init(
        permissions: .live(),
        runningWorkouts: .live(),
        support: .live(),
        observation: .live()
    )
}
