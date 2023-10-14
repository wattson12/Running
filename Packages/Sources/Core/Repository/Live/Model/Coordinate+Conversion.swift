import Cache
import Foundation
import Model

extension Model.Location.Coordinate {
    init(cached: Cache.Coordinate) {
        self.init(
            latitude: cached.latitude,
            longitude: cached.longitude
        )
    }
}
