import Foundation
import HealthKit
import HealthKitServiceInterface

extension HealthKitRunningWorkouts {
    static func live(in store: HKHealthStore = .shared) -> Self {
        .init(
            allRunningWorkouts: {
                try await Implementation.allRunningWorkouts(in: store)
            }
        )
    }

    private enum Implementation {
        static func allRunningWorkouts(in store: HKHealthStore) async throws -> [HKWorkout] {
            try await withCheckedThrowingContinuation { [store] continuation in
                let predicate = HKQuery.predicateForWorkouts(with: .running)

                let sampleQuery = HKSampleQuery(
                    sampleType: .workoutType(),
                    predicate: predicate,
                    limit: HKObjectQueryNoLimit,
                    sortDescriptors: [
                        .init(keyPath: \HKSample.startDate, ascending: false),
                    ],
                    resultsHandler: { _, samples, error in

                        if let error {
                            continuation.resume(throwing: error)
                            return
                        }

                        let samples = samples as? [HKWorkout]

                        continuation.resume(with: .success(samples ?? []))
                    }
                )

                store.execute(sampleQuery)
            }
        }
    }
}
