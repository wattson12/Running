import Cache
import Dependencies
import Foundation
import HealthKitServiceInterface
import Model
import SwiftData

extension RunningWorkouts {
    static func live() -> Self {
        @Dependency(\.swiftData) var swiftData
        @Dependency(\.healthKit.runningWorkouts) var healthKitRunningWorkouts
        @Dependency(\.calendar) var calendar
        @Dependency(\.date) var date

        return .init(
            allRunningWorkouts: .init(
                cache: {
                    Implementation.cachedRunningWorkouts(
                        swiftData: swiftData
                    )
                },
                remote: {
                    try await Implementation.remoteRunningWorkouts(
                        swiftData: swiftData,
                        healthKitRunningWorkouts: healthKitRunningWorkouts
                    )
                }
            ),
            runDetail: { id in
                try await Implementation.runDetail(
                    id: id,
                    swiftData: swiftData,
                    healthKitRunningWorkouts: healthKitRunningWorkouts
                )
            }
        )
    }

    private enum Implementation {
        static func cachedRunningWorkouts(
            swiftData: SwiftDataStack
        ) -> [Model.Run]? {
            do {
                let context = try swiftData.context()
                let descriptor: FetchDescriptor<Cache.Run> = FetchDescriptor(sortBy: [.init(\.startDate, order: .forward)])

                let runs = try context.fetch(descriptor)
                    .map(Run.init(cached:))
                return runs.isEmpty ? nil : runs
            } catch {
                return nil
            }
        }

        @MainActor
        static func remoteRunningWorkouts(
            swiftData: SwiftDataStack,
            healthKitRunningWorkouts: HealthKitRunningWorkouts
        ) async throws -> [Model.Run] {
            let runs = try await healthKitRunningWorkouts
                .allRunningWorkouts()
                .compactMap(Run.init(model:))

            let context = try swiftData.context()

            var runsNeedingUpdate: [Model.Run.ID: Cache.Run] = [:]
            for run in runs {
                let runsMatchingID = try context.fetch(
                    .init(
                        predicate: #Predicate<Cache.Run> { [id = run.id] run in
                            run.id == id
                        }
                    )
                )
                if let existingRun = runsMatchingID.first {
                    existingRun.startDate = run.startDate
                    existingRun.distance = run.distance.value
                    existingRun.duration = run.duration.value
                    runsNeedingUpdate[existingRun.id] = existingRun
                } else {
                    let cacheValue = Cache.Run(
                        id: run.id,
                        startDate: run.startDate,
                        distance: run.distance.value,
                        duration: run.duration.value,
                        detail: nil
                    )
                    context.insert(cacheValue)
                }
            }

            let responseIDs = runs.map(\.id)
            let runsNotInResponse = try context.fetch(
                .init(
                    predicate: #Predicate<Cache.Run> { run in
                        !responseIDs.contains(run.id)
                    }
                )
            )
            runsNotInResponse.forEach(context.delete)

            try context.save()

            return runs.map { run in
                guard let updatedRunEntity = runsNeedingUpdate[run.id] else { return run }
                return .init(cached: updatedRunEntity)
            }
        }

        @MainActor
        static func runDetail(
            id: Model.Run.ID,
            swiftData: SwiftDataStack,
            healthKitRunningWorkouts: HealthKitRunningWorkouts
        ) async throws -> Model.Run {
            let remoteDetail = try await healthKitRunningWorkouts.detail(for: id)

            let context = try swiftData.context()

            let runsMatchingID = try context.fetch(.init(predicate: #Predicate<Cache.Run> { $0.id == id }))

            guard let run = runsMatchingID.first else {
                // should always have a run matching the ID
                throw RepositoryError(message: "Unable to find existing run with ID: \(id)")
            }

            let locations: [Cache.Location] = remoteDetail.locations.map { location in
                .init(
                    latitude: location.coordinate.latitude,
                    longitude: location.coordinate.longitude,
                    altitude: location.altitude,
                    timestamp: location.timestamp
                )
            }

            let samples: [Cache.DistanceSample] = remoteDetail.samples.map { sample in
                .init(
                    startDate: sample.startDate,
                    distance: sample.sumQuantity.doubleValue(for: .meter())
                )
            }

            run.detail = .init(
                locations: locations,
                distanceSamples: samples
            )

            try context.save()

            return .init(cached: run)
        }
    }
}
