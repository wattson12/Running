import Cache
import Dependencies
import Foundation
import HealthKitServiceInterface
import Model

extension RunningWorkouts {
    static func live() -> Self {
        @Dependency(\.coreData) var coreData
        @Dependency(\.healthKit.runningWorkouts) var healthKitRunningWorkouts
        @Dependency(\.calendar) var calendar

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
            cachedRun: { id in
                Implementation.cachedRunningWorkout(id: id, coreData: coreData)
            },
            runDetail: { id in
                try await Implementation.runDetail(
                    id: id,
                    coreData: coreData,
                    healthKitRunningWorkouts: healthKitRunningWorkouts
                )
            },
            runsWithinGoal: { goal, date in
                try Implementation.runsWithinGoal(
                    goal: goal,
                    coreData: coreData,
                    calendar: calendar,
                    date: date
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
                        .init(keyPath: \Cache.RunEntity.startDate, ascending: false),
                    ]
                    let runs = try context.fetch(fetchRequest)
                    return runs.isEmpty ? nil : runs.map { Model.Run(entity: $0, includeDetail: false) }
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
                    return .init(entity: updatedRunEntity, includeDetail: false)
                }
            }
        }

        @MainActor
        static func runDetail(
            id: Model.Run.ID,
            coreData: CoreDataStack,
            healthKitRunningWorkouts: HealthKitRunningWorkouts
        ) async throws -> Model.Run {
            let remoteDetail = try await healthKitRunningWorkouts.detail(for: id)

            return try coreData.performWork { context in
                let fetchRequestForRunsMatchingID = RunEntity.makeFetchRequest()
                fetchRequestForRunsMatchingID.predicate = .init(format: "id == %@", id as NSUUID)
                let runsMatchingID = try context.fetch(fetchRequestForRunsMatchingID)

                guard let run = runsMatchingID.first else {
                    // should always have a run matching the ID
                    throw RepositoryError(message: "Unable to find existing run with ID: \(id)")
                }

                let locations: [Cache.LocationEntity] = remoteDetail
                    .locations
                    .sorted(by: { $0.timestamp < $1.timestamp })
                    .map { location in
                        let locationEntity = LocationEntity(context: context)
                        locationEntity.latitude = location.coordinate.latitude
                        locationEntity.longitude = location.coordinate.longitude
                        locationEntity.altitude = location.altitude
                        locationEntity.timestamp = location.timestamp
                        return locationEntity
                    }

                let samples: [Cache.DistanceSampleEntity] = remoteDetail.samples.map { sample in
                    let distanceSampleEntity = DistanceSampleEntity(context: context)
                    distanceSampleEntity.startDate = sample.startDate
                    distanceSampleEntity.distance = sample.sumQuantity.doubleValue(for: .meter())
                    return distanceSampleEntity
                }

                let runDetail = RunDetailEntity(context: context)
                runDetail.locations = Set(locations)
                runDetail.distanceSamples = Set(samples)
                run.detail = runDetail

                try context.save()

                return .init(entity: run, includeDetail: true)
            }
        }

        #warning("remove this and instead add an optional predicate / date range to the allRunningWorkouts function")
        // this could be an extension with the same signature which uses the date range
        static func runsWithinGoal(
            goal: Model.Goal,
            coreData: CoreDataStack,
            calendar: Calendar,
            date: Date
        ) throws -> [Model.Run] {
            guard let dates = goal.period.startAndEnd(in: calendar, now: date) else {
                throw RunningWorkoutsError.validation("Unable to create date range from goal: \(goal)")
            }
            let start = dates.start
            let end = dates.end

            return try coreData.performWork { context in
                let fetchRequest = RunEntity.makeFetchRequest()
                fetchRequest.predicate = .init(format: "startDate >= %@ && startDate < %@", start as NSDate, end as NSDate)
                fetchRequest.sortDescriptors = [
                    .init(keyPath: \RunEntity.startDate, ascending: false),
                ]

                return try context.fetch(fetchRequest).map { Run(entity: $0, includeDetail: false) }
            }
        }
    }
}
