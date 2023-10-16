import Foundation
import SwiftData

@Model
public class Location {
    public var latitude: Double
    public var longitude: Double
    public var altitude: Double
    public var timestamp: Date

    public init(
        latitude: Double,
        longitude: Double,
        altitude: Double,
        timestamp: Date
    ) {
        self.latitude = latitude
        self.longitude = longitude
        self.altitude = altitude
        self.timestamp = timestamp
    }
}
