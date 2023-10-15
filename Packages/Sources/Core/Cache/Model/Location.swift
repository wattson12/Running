import Foundation
import SwiftData

@Model
public class Location {
    public var coordinate: Coordinate
    public var altitude: Double
    public var timestamp: Date

    public init(
        coordinate: Coordinate,
        altitude: Double,
        timestamp: Date
    ) {
        self.coordinate = coordinate
        self.altitude = altitude
        self.timestamp = timestamp
    }
}
