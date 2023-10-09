import ConcurrencyExtras
import CoreLocation
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

                let queries: LockIsolated<[HKQuery]> = .init([])
                continuation.onTermination = { [queries] test in
                    switch test {
                    case .finished:
                        break
                    case .cancelled:
                        for query in queries.value {
                            store.stop(query)
                        }
                    @unknown default:
                        break
                    }
                }

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

                                let runningObjectQuery = HKQuery.predicateForObjects(from: sample)

                                let routeQuery = HKAnchoredObjectQuery(type: HKSeriesType.workoutRoute(), predicate: runningObjectQuery, anchor: nil, limit: HKObjectQueryNoLimit) { _, routeSamples, _, _, _ in
                                    guard let route = routeSamples?.first as? HKWorkoutRoute else {
                                        return
                                    }

                                    var allLocations: [CLLocation] = []
                                    let query = HKWorkoutRouteQuery(route: route) { _, locations, done, error in

                                        if let error {
                                            print(error)
                                            return
                                        }

                                        guard let locations else {
                                            print("missing samples")
                                            return
                                        }

                                        allLocations.append(contentsOf: locations)

                                        if done {
                                            print("locations", allLocations.count)
                                            continuation.yield(sample)
                                        }
                                    }

                                    queries.setValue(queries.value + [query])
                                    store.execute(query)
                                }

                                queries.setValue(queries.value + [routeQuery])
                                store.execute(routeQuery)
                            }
                        }
                    }
                )

                queries.setValue(queries.value + [sampleQuery])
                store.execute(sampleQuery)
            }
        }
    }
}
