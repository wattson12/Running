import Cache
import Foundation
import Model

extension Model.Location {
    init(cached: Cache.Location) {
        self.init(
            coordinate: .init(cached: cached.coordinate),
            altitude: .init(value: cached.altitude, unit: .meters),
            timestamp: cached.timestamp
        )
    }
}
