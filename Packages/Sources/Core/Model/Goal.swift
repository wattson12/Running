import Foundation

public struct Goal: Equatable {
    public enum Period: String, Equatable, Sendable, Hashable, CaseIterable {
        case weekly
        case monthly
        case yearly
    }

    public var period: Period
    public var target: Measurement<UnitLength>?

    public init(
        period: Period,
        target: Measurement<UnitLength>?
    ) {
        self.period = period
        self.target = target
    }
}

public extension Goal {
    static func mock(
        period: Period = .weekly,
        target: Measurement<UnitLength>? = .init(
            value: 50,
            unit: .kilometers
        )
    ) -> Self {
        .init(
            period: period,
            target: target
        )
    }
}
