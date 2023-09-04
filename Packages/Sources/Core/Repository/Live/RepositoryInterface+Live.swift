import Dependencies
import Foundation

extension RepositoryInterfaceDependencyKey: DependencyKey {
    public static var liveValue: RepositoryInterface = .init(
        goals: .live(),
        permissions: .live(),
        runningWorkouts: .live(),
        support: .live()
    )
}
