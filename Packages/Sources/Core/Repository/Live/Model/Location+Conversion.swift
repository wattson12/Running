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
}
