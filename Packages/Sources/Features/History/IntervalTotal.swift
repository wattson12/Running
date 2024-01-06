import Dependencies
import Foundation
import Model

public struct IntervalTotal: Identifiable, Equatable {
    public let id: UUID
    public let period: Goal.Period
    public let date: Date
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

        var totals: [(Measurement<UnitLength>, Date)] = .init(repeating: (.init(value: 0, unit: .kilometers), .now), count: lastYear - firstYear + 1)
        for run in runs {
            let year = calendar.component(.year, from: run.startDate)
            var currentTotal = totals[year - firstYear]
            currentTotal.0 = currentTotal.0 + run.distance
            currentTotal.1 = run.startDate
            totals[year - firstYear] = currentTotal
        }

        self = totals.enumerated().map {
            index,
                totalValues in
            .init(
                id: uuid(),
                period: .yearly,
                date: totalValues.1,
                label: (index + firstYear).description,
                sort: index + firstYear,
                distance: totalValues.0
            )
        }
    }
}
