import Dependencies
import Foundation
import HealthKitServiceInterface

extension HealthKitServiceInterfaceDependencyKey: DependencyKey {
    public static let liveValue: HealthKitServiceInterface = .init(
        permissions: .live(),
        runningWorkouts: .live(),
        support: .live(),
        observation: .live()
    )
}
