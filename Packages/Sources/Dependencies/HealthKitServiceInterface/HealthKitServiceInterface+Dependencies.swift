import Dependencies
import Foundation

public enum HealthKitServiceInterfaceDependencyKey: TestDependencyKey {
    public static var previewValue: HealthKitServiceInterface = .init(
        permissions: .previewValue,
        runningWorkouts: .previewValue,
        support: .previewValue,
        observation: .previewValue
    )

    public static var testValue: HealthKitServiceInterface = .init(
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
