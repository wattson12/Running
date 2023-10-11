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

        static func runDetail(
            id: Model.Run.ID,
            swiftData: SwiftDataStack,
            healthKitRunningWorkouts: HealthKitRunningWorkouts
        ) async throws -> Model.Run {
            let context = try swiftData.context()

            let runsMatchingID = try context.fetch(.init(predicate: #Predicate<Cache.Run> { $0.id == id }))
            guard let run = runsMatchingID.first else {
                // should always have a run matching the ID
                throw NSError(domain: #fileID, code: #line)
            }

            // if run already has detail
            if !run.locations.isEmpty, !run.distanceSamples.isEmpty {
                return .init(cached: run)
            }

//            throw NSError(domain: #fileID, code: #line)

//            print(Thread.current)
            print("about to fetch remote")
            let remoteDetail = try await healthKitRunningWorkouts.detail(for: id)
            print("fetched remote")
//            print(Thread.current)

            run.locations = remoteDetail.locations.map { location in
                .init(
                    coordinate: .init(
                        latitude: location.coordinate.latitude,
                        longitude: location.coordinate.longitude
                    ),
                    altitude: location.altitude,
                    timestamp: location.timestamp
                )
            }
            run.distanceSamples = remoteDetail.samples.map { sample in
                .init(
                    startDate: sample.startDate,
                    distance: sample.sumQuantity.doubleValue(for: .meter())
                )
            }

            try context.save()

            return .init(cached: run)
        }

        static func remoteRunningWorkouts(
            swiftData: SwiftDataStack,
            healthKitRunningWorkouts: HealthKitRunningWorkouts
        ) async throws -> [Model.Run] {
            let runs = try await healthKitRunningWorkouts
                .allRunningWorkouts()
                .compactMap(Run.init(model:))

            let context = try swiftData.context()

            for run in runs {
                let runID = run.id
                let runsMatchingID = try context.fetch(.init(predicate: #Predicate<Cache.Run> { $0.id == runID }))
                if let existingRun = runsMatchingID.first {
                    existingRun.startDate = run.startDate
                    existingRun.distance = run.distance.value
                    existingRun.duration = run.duration.value
                } else {
                    let cacheValue = Cache.Run(
                        id: run.id,
                        startDate: run.startDate,
                        distance: run.distance.value,
                        duration: run.duration.value,
                        locations: [], // empty until detail is fetched
                        distanceSamples: [] // empty until detail is fetched
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

            return runs
        }

        static func runsWithinGoal(
            goal: Model.Goal,
            swiftData: SwiftDataStack,
            calendar: Calendar,
            date: Date
        ) throws -> [Model.Run] {
            guard let dates = goal.period.startAndEnd(in: calendar, now: date) else {
                throw RunningWorkoutsError.validation("Unable to create date range from goal: \(goal)")
            }
            let start = dates.start
            let end = dates.end

            let context = try swiftData.context()
            let descriptor: FetchDescriptor<Cache.Run> = FetchDescriptor(
                predicate: #Predicate<Cache.Run> {
                    $0.startDate >= start && $0.startDate < end
                },
                sortBy: [.init(\.startDate, order: .forward)]
            )

            return try context.fetch(descriptor).map(Run.init(cached:))
        }
    }
}
