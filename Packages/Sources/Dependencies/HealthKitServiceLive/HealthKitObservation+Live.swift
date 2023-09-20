import DependenciesAdditions
import Foundation
import HealthKit
import HealthKitServiceInterface
import Model

extension HealthKitObservation {
    static func live() -> Self {
        @Dependency(\.userDefaults) var userDefaults

        return .init(
            enableBackgroundDelivery: {
                try await HKHealthStore.shared.enableBackgroundDelivery(for: .workoutType(), frequency: .immediate)
            },
            observeWorkouts: {
                let predicate = HKQuery.predicateForWorkouts(with: .running)
                let query = HKObserverQuery(
                    sampleType: .workoutType(),
                    predicate: predicate,
                    updateHandler: { _, completionHandler, _ in
                        completionHandler()
                    }
                )
                HKHealthStore.shared.execute(query)
            }
        )
    }
}
