import Cache
import Foundation
import Model

extension Model.DistanceSample {
    init(entity: Cache.DistanceSampleEntity) {
        self.init(
            startDate: entity.startDate,
            distance: .init(value: entity.distance, unit: .meters)
        )
    }
}
