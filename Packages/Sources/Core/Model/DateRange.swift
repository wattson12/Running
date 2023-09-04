import Foundation

public struct DateRange: Equatable, Identifiable, Sendable {
    public var id: Date { start }
    public let period: Goal.Period
    public let start: Date
    public let end: Date

    public init(
        period: Goal.Period,
        start: Date,
        end: Date
    ) {
        self.period = period
        self.start = start
        self.end = end
    }
}

public extension DateRange {
    static func mock(
        period: Goal.Period = .weekly,
        start: Date = .now,
        end: Date = Calendar.current.date(byAdding: .weekOfYear, value: 1, to: .now) ?? .now.addingTimeInterval(7 * 24 * 60 * 60)
    ) -> DateRange {
        .init(
            period: period,
            start: start,
            end: end
        )
    }
}
