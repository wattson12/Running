import Dependencies
import Foundation

public enum HealthKitServiceInterfaceDependencyKey: TestDependencyKey {
    public static let previewValue: HealthKitServiceInterface = .init(
        permissions: .previewValue,
        runningWorkouts: .previewValue,
        support: .previewValue,
        observation: .previewValue
    )

    public static let testValue: HealthKitServiceInterface = .init(
        permissions: .testValue,
        runningWorkouts: .testValue,
        support: .testValue,
        observation: .testValue
    )
}

public extension DependencyValues {
    var healthKit: HealthKitServiceInterface {
        get { self[HealthKitServiceInterfaceDependencyKey.self] }
        set { self[HealthKitServiceInterfaceDependencyKey.self] = newValue }
    }
}
