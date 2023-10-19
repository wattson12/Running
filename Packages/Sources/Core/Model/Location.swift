import Foundation

public struct Location: Equatable, Hashable {
    public struct Coordinate: Equatable, Hashable {
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
