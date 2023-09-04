import Foundation
import Model

struct ChartColumn: Equatable, Identifiable {
    let id: UUID = .init()
    let index: String
    let label: String
    let runs: [ChartRun]
    let cumulativeDistance: Measurement<UnitLength>
    let displayCumulativeDistance: Bool
}

extension [ChartColumn] {
    static func weekly(runs: [Run], calendar: Calendar = .current) -> Self {
        columns(
            runs: runs,
            calendar: calendar,
            intervalComponents: [.calendar, .yearForWeekOfYear, .weekOfYear],
            intervalComponent: .weekOfYear,
            columnComponent: .day,
            labelDateFormat: "EEE"
        )
    }

    static func monthly(runs: [Run], calendar: Calendar = .current) -> Self {
        columns(
            runs: runs,
            calendar: calendar,
            intervalComponents: [.calendar, .year, .month],
            intervalComponent: .month,
            columnComponent: .day,
            labelDateFormat: "dd"
        )
    }

    static func yearly(runs: [Run], calendar: Calendar = .current) -> Self {
        columns(
            runs: runs,
            calendar: calendar,
            intervalComponents: [.calendar, .year],
            intervalComponent: .year,
            columnComponent: .month,
            labelDateFormat: "MMM"
        )
    }

    static func columns(
        runs: [Run],
        calendar: Calendar = .current,
        intervalComponents: Set<Calendar.Component>,
        intervalComponent: Calendar.Component,
        columnComponent: Calendar.Component,
        labelDateFormat: String
    ) -> Self {
        guard let startDate = runs.first?.startDate else { return [] }

        guard let startOfInterval = calendar.dateComponents(intervalComponents, from: startDate).date else { return [] }

        var days: [Date] = []

        var currentDate = startOfInterval
        while calendar.isDate(currentDate, equalTo: startOfInterval, toGranularity: intervalComponent) {
            days.append(currentDate)
            guard let nextDate = calendar.date(byAdding: columnComponent, value: 1, to: currentDate) else { break }
            currentDate = nextDate
        }

        var values: [ChartColumn] = []
        var cumulativeDistance: Measurement<UnitLength> = .init(value: 0, unit: .kilometers)

        let formatter = DateFormatter()
        formatter.dateFormat = labelDateFormat

        for (index, day) in days.enumerated() {
            let matchingRuns = runs.filter {
                calendar.isDate($0.startDate, equalTo: day, toGranularity: columnComponent)
            }

            for run in matchingRuns {
                cumulativeDistance = cumulativeDistance + run.distance
            }

            values.append(
                .init(
                    index: index.description,
                    label: formatter.string(from: day),
                    runs: .init(runs: matchingRuns),
                    cumulativeDistance: cumulativeDistance,
                    displayCumulativeDistance: day <= Date()
                )
            )
        }

        return values
    }
}
