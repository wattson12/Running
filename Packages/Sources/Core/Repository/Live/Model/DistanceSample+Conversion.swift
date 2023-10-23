import Cache
import Foundation
import Model

extension Model.DistanceSample {
    init(cached: Cache.DistanceSample) {
        self.init(
            startDate: cached.startDate,
            distance: .init(value: cached.distance, unit: .meters)
        )
    }

    init(entity: Cache.DistanceSampleEntity) {
        self.init(
            startDate: entity.startDate,
            distance: .init(value: entity.distance, unit: .meters)
        )
    }
}
