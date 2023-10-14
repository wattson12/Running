import Foundation
import SwiftData

@Model
public class Location {
    public let coordinate: Coordinate
    public let altitude: Double
    public let timestamp: Date

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
