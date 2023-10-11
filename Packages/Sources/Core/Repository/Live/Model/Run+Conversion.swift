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
            locations: [],
            distanceSamples: []
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
            locations: cached.locations.map { location in
                print("mapping location")
                return Model.Location(coordinate: .init(latitude: 0, longitude: 0), altitude: .init(value: 0, unit: .meters), timestamp: .now)
                return Model.Location(
                    coordinate: .init(
                        latitude: location.coordinate.latitude,
                        longitude: location.coordinate.longitude
                    ),
                    altitude: .init(value: location.altitude, unit: .meters),
                    timestamp: location.timestamp
                )
            },
            distanceSamples: cached.distanceSamples.map { sample in
                print("mapping sample")
                return .init(startDate: .now, distance: .init(value: 0, unit: .meters))
                return Model.DistanceSample(
                    startDate: sample.startDate,
                    distance: .init(value: sample.distance, unit: .meters)
                )
            }
        )
    }
}
