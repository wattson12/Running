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
    init(entity: Cache.RunEntity) {
        self.init(
            id: entity.id,
            startDate: entity.startDate,
            distance: .init(value: entity.distance, unit: .meters),
            duration: .init(value: entity.duration, unit: .seconds),
            detail: entity.detail.map { detail in
                .init(
                    locations: detail.locations
                        .sorted(by: { $0.timestamp < $1.timestamp })
                        .map(Model.Location.init(entity:)),
                    distanceSamples: detail.distanceSamples.map(Model.DistanceSample.init(entity:))
                )
            }
        )
    }
}
