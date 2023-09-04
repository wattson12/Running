import Dependencies
import Model
import XCTestDynamicOverlay

public enum RepositoryInterfaceDependencyKey: TestDependencyKey {
    public static var previewValue: RepositoryInterface = .init(
        goals: .previewValue,
        permissions: .previewValue,
        runningWorkouts: .previewValue,
        support: .previewValue
    )

    public static var testValue: RepositoryInterface = .init(
        goals: .testValue,
        permissions: .testValue,
        runningWorkouts: .testValue,
        support: .testValue
    )
}

public extension DependencyValues {
    var repository: RepositoryInterface {
        get { self[RepositoryInterfaceDependencyKey.self] }
        set { self[RepositoryInterfaceDependencyKey.self] = newValue }
    }
}
