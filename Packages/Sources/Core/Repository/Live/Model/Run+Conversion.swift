import Cache
import Foundation
import HealthKit
import HealthKitServiceInterface
import Model

extension Model.Run {
    init?(model: WorkoutType) {
        guard let distanceWalkingRunningStatistics = model.stats(for: .init(.distanceWalkingRunning)) else { return nil }
        guard let distanceQuantity = distanceWalkingRunningStatistics.sumQuantity() else { return nil }

        let distance = distanceQuantity.doubleValue(for: .meter())

        self.init(
            id: model.uuid,
            startDate: model.startDate,
            distance: .init(value: distance, unit: .meters),
            duration: .init(value: model.duration, unit: .seconds),
            detail: nil
        )
    }
}

extension Model.Run {
    init(cached: Cache.Run) {
        self.init(
            id: cached.id,
            startDate: cached.startDate,
            distance: .init(value: cached.distance, unit: .meters),
            duration: .init(value: cached.duration, unit: .seconds),
            detail: cached.detail.map { detail in
                .init(
                    locations: detail.locations
                        .sorted(by: { $0.timestamp < $1.timestamp })
                        .map(Model.Location.init(cached:)),
                    distanceSamples: detail.distanceSamples.map(Model.DistanceSample.init(cached:))
                )
            }
        )
    }
}
