import Foundation
import SwiftData

@Model
public class Coordinate {
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

@Model
public class DistanceSample {
    public let startDate: Date
    public let distance: Double

    public init(
        startDate: Date,
        distance: Double
    ) {
        self.startDate = startDate
        self.distance = distance
    }
}

@Model
public class Run {
    public let id: UUID
    public var startDate: Date
    public var distance: Double
    public var duration: Double
    public var locations: [Location]
    public var distanceSamples: [DistanceSample]

    public init(
        id: UUID,
        startDate: Date,
        distance: Double,
        duration: Double,
        locations: [Location],
        distanceSamples: [DistanceSample]
    ) {
        self.id = id
        self.startDate = startDate
        self.distance = distance
        self.duration = duration
        self.locations = locations
        self.distanceSamples = distanceSamples
    }
}
