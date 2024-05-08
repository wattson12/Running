import Foundation

public struct Location: Equatable, Hashable, Identifiable, Codable {
    public struct Coordinate: Equatable, Hashable, Codable {
        public let latitude: Double
        public let longitude: Double

        public init(
            latitude: Double,
            longitude: Double
        ) {
            self.latitude = latitude
            self.longitude = longitude
        }
    }

    public let coordinate: Coordinate
    public let altitude: Measurement<UnitLength>
    public let timestamp: Date

    public var id: Date { timestamp }

    public init(
        coordinate: Coordinate,
        altitude: Measurement<UnitLength>,
        timestamp: Date
    ) {
        self.coordinate = coordinate
        self.altitude = altitude
        self.timestamp = timestamp
    }
}
