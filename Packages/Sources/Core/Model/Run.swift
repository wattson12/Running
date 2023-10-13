import Dependencies
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

public struct DistanceSample: Equatable, Hashable {
    public let startDate: Date
    public let distance: Measurement<UnitLength>

    public init(
        startDate: Date,
        distance: Measurement<UnitLength>
    ) {
        self.startDate = startDate
        self.distance = distance
    }
}

public struct Run: Equatable, Hashable, Identifiable {
    public var id: UUID
    public var startDate: Date
    public var distance: Measurement<UnitLength>
    public var duration: Measurement<UnitDuration>
    public var locations: [Location]
    public var distanceSamples: [DistanceSample]

    public init(
        id: UUID,
        startDate: Date,
        distance: Measurement<UnitLength>,
        duration: Measurement<UnitDuration>,
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

public extension Run {
    static func mock(
        id: UUID = .init(),
        startDate: Date = Date(timeIntervalSinceNow: .random(in: 1 ..< 1_000_000)),
        distance: Measurement<UnitLength> = .init(value: .random(in: 1 ..< 50), unit: .kilometers),
        duration: Measurement<UnitDuration> = .init(value: 30, unit: .minutes),
        locations: [Location] = [],
        distanceSamples: [DistanceSample] = []
    ) -> Self {
        .init(
            id: id,
            startDate: startDate,
            distance: distance,
            duration: duration,
            locations: locations,
            distanceSamples: distanceSamples
        )
    }

    static func mock(
        offset days: Int,
        distance: Double,
        duration: Double = 30
    ) -> Run {
        @Dependency(\.date) var date
        @Dependency(\.calendar) var calendar

        return .mock(
            startDate: calendar.date(byAdding: .day, value: days, to: date.now)!,
            distance: .init(value: distance, unit: .kilometers),
            duration: .init(value: duration, unit: .minutes)
        )
    }

    static func mock(
        offset days: Int,
        distance: Double,
        pace: Double = 5,
        unit: UnitLength = .kilometers
    ) -> Run {
        @Dependency(\.date) var date
        @Dependency(\.calendar) var calendar

        return .mock(
            startDate: calendar.date(byAdding: .day, value: days, to: date.now)!,
            distance: .init(value: distance, unit: unit),
            duration: .init(value: pace * distance, unit: .minutes)
        )
    }
}
