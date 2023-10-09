import Foundation
import HealthKit
import HealthKitServiceInterface

extension HealthKitRunningWorkouts {
    static func live(in store: HKHealthStore = .shared) -> Self {
        .init(
            allRunningWorkouts: {
                try await Implementation.allRunningWorkouts(in: store)
            },
            runningWorkouts: {
                Implementation.runningWorkouts(in: store)
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

        static func runningWorkouts(in store: HKHealthStore) -> AsyncThrowingStream<WorkoutType, Error> {
            .init { [store] continuation in
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
                            continuation.finish(throwing: error)
                            return
                        }

                        if let samples = samples as? [HKWorkout] {
                            for sample in samples {
                                continuation.yield(sample)
                            }
                        }
                    }
                )

                store.execute(sampleQuery)
            }
        }
    }
}
