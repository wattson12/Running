import Cache
import Foundation
import Model

extension Model.Location {
    init(cached: Cache.Location) {
        self.init(
            coordinate: .init(latitude: cached.latitude, longitude: cached.longitude),
            altitude: .init(value: cached.altitude, unit: .meters),
            timestamp: cached.timestamp
        )
    }

    init(entity: Cache.LocationEntity) {
        self.init(
            coordinate: .init(latitude: entity.latitude, longitude: entity.longitude),
            altitude: .init(value: entity.altitude, unit: .meters),
            timestamp: entity.timestamp!
        )
        #warning("timestamp shouldnt be optional")
    }
}
