import Dependencies
import Foundation
import Model

public struct IntervalTotal: Identifiable, Equatable {
    public let id: UUID
    public let period: Goal.Period
    public let label: String
    public let sort: Int
    public let distance: Measurement<UnitLength>
}

extension [IntervalTotal] {
    init(runs: [Run]) {
        @Dependency(\.calendar) var calendar
        @Dependency(\.uuid) var uuid

        guard let first = runs.first, let last = runs.last else {
            self = []
            return
        }

        let firstYear = calendar.component(.year, from: first.startDate)
        let lastYear = calendar.component(.year, from: last.startDate)

        var totals: [Measurement<UnitLength>] = .init(repeating: .init(value: 0, unit: .kilometers), count: lastYear - firstYear + 1)
        for run in runs {
            let year = calendar.component(.year, from: run.startDate)
            var currentTotal = totals[year - firstYear]
            currentTotal = currentTotal + run.distance
            totals[year - firstYear] = currentTotal
        }

        self = totals.enumerated().map {
            index,
                distance in
            .init(
                id: uuid(),
                period: .yearly,
                label: (index + firstYear).description,
                sort: index + firstYear,
                distance: distance
            )
        }
    }
}
