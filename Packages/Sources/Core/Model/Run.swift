import Foundation

public struct Run: Equatable, Identifiable {
    public var id: UUID
    public var startDate: Date
    public var distance: Measurement<UnitLength>
    public var duration: Measurement<UnitDuration>

    public init(
        id: UUID,
        startDate: Date,
        distance: Measurement<UnitLength>,
        duration: Measurement<UnitDuration>
    ) {
        self.id = id
        self.startDate = startDate
        self.distance = distance
        self.duration = duration
    }
}

public extension Run {
    static func mock(
        id: UUID = .init(),
        startDate: Date = Date(timeIntervalSinceNow: .random(in: 1 ..< 1_000_000)),
        distance: Measurement<UnitLength> = .init(value: .random(in: 1 ..< 50), unit: .kilometers),
        duration: Measurement<UnitDuration> = .init(value: 30, unit: .minutes)
    ) -> Self {
        .init(
            id: id,
            startDate: startDate,
            distance: distance,
            duration: duration
        )
    }

    static func mock(
        date: String,
        distance: Double,
        duration: Double = 30
    ) -> Run {
        .mock(
            startDate: .mock(date: date),
            distance: .init(value: distance, unit: .kilometers),
            duration: .init(value: duration, unit: .minutes)
        )
    }
}
