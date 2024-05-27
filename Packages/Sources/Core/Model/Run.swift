import Dependencies
import Foundation

public struct Run: Equatable, Hashable, Identifiable, Codable {
    public var id: UUID
    public var startDate: Date
    public var distance: Measurement<UnitLength>
    public var duration: Measurement<UnitDuration>
    public var detail: Detail?

    public init(
        id: UUID,
        startDate: Date,
        distance: Measurement<UnitLength>,
        duration: Measurement<UnitDuration>,
        detail: Detail?
    ) {
        self.id = id
        self.startDate = startDate
        self.distance = distance
        self.duration = duration
        self.detail = detail
    }
}

public extension Run {
    static func mock(
        id: UUID = .init(),
        startDate: Date = Date(timeIntervalSinceNow: .random(in: 1 ..< 1_000_000)),
        distance: Measurement<UnitLength> = .init(value: .random(in: 1 ..< 50), unit: .kilometers),
        duration: Measurement<UnitDuration> = .init(value: 30, unit: .minutes),
        detail: Detail? = nil
    ) -> Self {
        .init(
            id: id,
            startDate: startDate,
            distance: distance,
            duration: duration,
            detail: detail
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

        let startDate: Date
        if days == 0, ProcessInfo.processInfo.environment["SCREENSHOT_LOCALE"] != nil {
            let currentDayStartDate = calendar.date(byAdding: .day, value: days, to: date.now)!
            startDate = calendar.date(byAdding: .hour, value: -2, to: currentDayStartDate)!
        } else {
            startDate = calendar.date(byAdding: .day, value: days, to: date.now)!
        }

        return .mock(
            startDate: startDate,
            distance: .init(value: distance, unit: unit),
            duration: .init(value: pace * distance, unit: .minutes)
        )
    }
}
