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
            detail: { id in
                try await Implementation.detail(in: store, id: id)
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

        static func detail(in store: HKHealthStore, id: UUID) async throws {
            print("fetching workout")
            let workout = try await workout(in: store, withID: id)
            print("fetching workout - complete")

            print("fetching route")
            let route = try await route(in: store, for: workout)
            print("fetching route - complete")

            print("fetching locations")
            let locations = try await locations(in: store, for: route)
            print("fetching locations - complete")

            print("fetching distance samples")
            let distanceSamples = try await distanceSamples(in: store, for: workout)
            print("fetching distance samples - complete")

            print("Location count", locations.count)
            print("distance samples count", distanceSamples.count)
        }

        private static func workout(in store: HKHealthStore, withID id: UUID) async throws -> HKWorkout {
            try await withCheckedThrowingContinuation { [store] (continuation: CheckedContinuation<HKWorkout, Error>) in
                let query = HKQuery.predicateForObject(with: id)

                let sampleQuery = HKSampleQuery(
                    sampleType: .workoutType(),
                    predicate: query,
                    limit: 1,
                    sortDescriptors: [
                        .init(keyPath: \HKSample.startDate, ascending: false),
                    ],
                    resultsHandler: { _, samples, error in

                        if let error {
                            continuation.resume(throwing: error)
                            return
                        }

                        let samples = samples as? [HKWorkout]

                        guard let first = samples?.first else {
                            continuation.resume(throwing: NSError(domain: #fileID, code: #line))
                            return
                        }

                        continuation.resume(returning: first)
                    }
                )

                store.execute(sampleQuery)
            }
        }

        private static func route(in store: HKHealthStore, for workout: HKWorkout) async throws -> HKWorkoutRoute? {
            try await withCheckedThrowingContinuation { [store] (continuation: CheckedContinuation<HKWorkoutRoute?, Error>) in
                let runningObjectQuery = HKQuery.predicateForObjects(from: workout)

                let routeQuery = HKAnchoredObjectQuery(type: HKSeriesType.workoutRoute(), predicate: runningObjectQuery, anchor: nil, limit: HKObjectQueryNoLimit) { _, samples, _, _, _ in
                    guard let first = samples?.first as? HKWorkoutRoute else {
                        continuation.resume(returning: nil)
                        return
                    }

                    continuation.resume(returning: first)
                }

                store.execute(routeQuery)
            }
        }

        private static func locations(in store: HKHealthStore, for route: HKWorkoutRoute?) async throws -> [CLLocation] {
            guard let route else { return [] }
            return try await withCheckedThrowingContinuation { continuation in
                var allLocations: [CLLocation] = []
                let query = HKWorkoutRouteQuery(route: route) { _, locations, done, error in

                    if let error {
                        continuation.resume(throwing: error)
                        return
                    }

                    guard let locations else {
                        continuation.resume(throwing: NSError(domain: #fileID, code: #line))
                        return
                    }

                    allLocations.append(contentsOf: locations)

                    if done {
                        continuation.resume(returning: allLocations)
                    }
                }

                store.execute(query)
            }
        }

        private static func distanceSamples(in store: HKHealthStore, for workout: HKWorkout) async throws -> [HKCumulativeQuantitySample] {
            try await withCheckedThrowingContinuation { continuation in

                let query = HKSampleQuery(
                    sampleType: HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
                    predicate: HKQuery.predicateForObjects(from: workout),
                    limit: HKObjectQueryNoLimit,
                    sortDescriptors: [
                        .init(keyPath: \HKSample.startDate, ascending: false),
                    ],
                    resultsHandler: { _, samples, error in
                        guard error == nil else {
                            continuation.resume(throwing: error ?? NSError(domain: #fileID, code: #line))
                            return
                        }

                        guard let samples = samples as? [HKCumulativeQuantitySample] else {
                            continuation.resume(throwing: NSError(domain: #fileID, code: #line))
                            return
                        }

                        continuation.resume(returning: samples)
                    }
                )

                store.execute(query)
            }
        }
    }
}
