import Cache
import Foundation
import Model

extension Model.Location {
    init(entity: Cache.LocationEntity) {
        self.init(
            coordinate: .init(latitude: entity.latitude, longitude: entity.longitude),
            altitude: .init(value: entity.altitude, unit: .meters),
            timestamp: entity.timestamp
        )
    }
}
