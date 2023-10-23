import Cache
import Dependencies
import Foundation
import HealthKitServiceInterface
import Model

extension RunningWorkouts {
    static func live() -> Self {
        @Dependency(\.swiftData) var swiftData
        @Dependency(\.coreData) var coreData
        @Dependency(\.healthKit.runningWorkouts) var healthKitRunningWorkouts
        @Dependency(\.calendar) var calendar
        @Dependency(\.date) var date

        return .init(
            allRunningWorkouts: .init(
                cache: {
                    Implementation.cachedRunningWorkouts(
                        coreData: coreData
                    )
                },
                remote: {
                    try await Implementation.remoteRunningWorkouts(
                        coreData: coreData,
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
            },
            runsWithinGoal: { goal in
                try Implementation.runsWithinGoal(
                    goal: goal,
                    swiftData: swiftData,
                    calendar: calendar,
                    date: date.now
                )
            }
        )
    }

    private enum Implementation {
        static func cachedRunningWorkouts(
            coreData: CoreDataStack
        ) -> [Model.Run]? {
            do {
                return try coreData.performWork { context in
                    let fetchRequest = Cache.RunEntity.makeFetchRequest()
                    fetchRequest.sortDescriptors = [
                        .init(keyPath: \Cache.RunEntity.startDate, ascending: true),
                    ]
                    let runs = try context.fetch(fetchRequest)
                    return runs.isEmpty ? nil : runs.map(Model.Run.init(entity:))
                }
            } catch {
                return nil
            }
        }

        @MainActor
        static func remoteRunningWorkouts(
            coreData: CoreDataStack,
            healthKitRunningWorkouts: HealthKitRunningWorkouts
        ) async throws -> [Model.Run] {
            let runs = try await healthKitRunningWorkouts
                .allRunningWorkouts()
                .compactMap(Run.init(model:))

            return try coreData.performWork { context in

                var runsNeedingUpdate: [Model.Run.ID: Cache.RunEntity] = [:]
                for run in runs {
                    let fetchRequestForRunsMatchingID = Cache.RunEntity.makeFetchRequest()
                    fetchRequestForRunsMatchingID.predicate = .init(format: "id == %@", run.id.uuidString)
                    let runsMatchingID = try context.fetch(fetchRequestForRunsMatchingID)

                    if let existingRun = runsMatchingID.first {
                        existingRun.startDate = run.startDate
                        existingRun.distance = run.distance.value
                        existingRun.duration = run.duration.value
                        runsNeedingUpdate[existingRun.id] = existingRun
                    } else {
                        let newRun = Cache.RunEntity(context: context)
                        newRun.id = run.id
                        newRun.startDate = run.startDate
                        newRun.distance = run.distance.converted(to: .meters).value
                        newRun.duration = run.duration.converted(to: .seconds).value
                    }
                }

                let responseIDs = runs.map(\.id)
                let fetchRequestForRunsNotInResponse = Cache.RunEntity.makeFetchRequest()
                fetchRequestForRunsNotInResponse.predicate = .init(format: "NOT (id IN %@)", responseIDs)
                let runsNotInResponse = try context.fetch(fetchRequestForRunsNotInResponse)
                runsNotInResponse.forEach(context.delete)

                try context.save()

                return runs.map { run in
                    guard let updatedRunEntity = runsNeedingUpdate[run.id] else { return run }
                    return .init(entity: updatedRunEntity)
                }
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

            let locations: [Cache.Location] = remoteDetail
                .locations
                .sorted(by: { $0.timestamp < $1.timestamp })
                .map { location in
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

        #warning("remove this and instead add an optional predicate / date range to the allRunningWorkouts function")
        // this could be an extension with the same signature which uses the date range
        static func runsWithinGoal(
            goal _: Model.Goal,
            swiftData _: SwiftDataStack,
            calendar _: Calendar,
            date _: Date
        ) throws -> [Model.Run] {
            []
//            guard let dates = goal.period.startAndEnd(in: calendar, now: date) else {
//                throw RunningWorkoutsError.validation("Unable to create date range from goal: \(goal)")
//            }
//            let start = dates.start
//            let end = dates.end
//
//            let context = try swiftData.context()
//            let descriptor: FetchDescriptor<Cache.Run> = FetchDescriptor(
//                predicate: #Predicate<Cache.Run> {
//                    $0.startDate >= start && $0.startDate < end
//                },
//                sortBy: [.init(\.startDate, order: .forward)]
//            )
//
//            return try context.fetch(descriptor).map(Run.init(cached:))
        }
    }
}
