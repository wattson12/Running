import Charts
import DesignSystem
import Model
import SwiftUI

struct GoalChartView: View {
    let columns: [ChartColumn]
    let goal: Measurement<UnitLength>?
    let visibleColumnCount: Int

    @Environment(\.tintColor) var tint

    init(
        period: Goal.Period,
        runs: [Run],
        goal: Measurement<UnitLength>?
    ) {
        switch period {
        case .weekly:
            columns = .weekly(runs: runs)
            visibleColumnCount = 7
        case .monthly:
            columns = .monthly(runs: runs)
            visibleColumnCount = 20
        case .yearly:
            columns = .yearly(runs: runs)
            visibleColumnCount = 12
        }
        self.goal = goal
    }

    var body: some View {
        Chart {
            ForEach(columns) { column in
                if !column.runs.isEmpty {
                    ForEach(column.runs) { run in
                        BarMark(
                            x: .value("index", column.index),
                            yStart: .value("distance", run.start.converted(to: .primaryUnit()).value),
                            yEnd: .value("distance", run.end.converted(to: .primaryUnit()).value)
                        )
                        .foregroundStyle(by: .value("run", run.id.uuidString))
                        .cornerRadius(0)
                    }
                } else {
                    BarMark(
                        x: .value("index", column.index),
                        y: .value("distance", 0)
                    )
                }

                if column.displayCumulativeDistance {
                    LineMark(
                        x: .value("index", column.index),
                        y: .value("distance", column.cumulativeDistance.converted(to: .primaryUnit()).value)
                    )
                    .foregroundStyle(tint)
                    .interpolationMethod(.monotone)

                    AreaMark(
                        x: .value("index", column.index),
                        y: .value("distance", column.cumulativeDistance.converted(to: .primaryUnit()).value)
                    )
                    .interpolationMethod(.monotone)
                    .foregroundStyle(
                        .linearGradient(
                            colors: [tint, .clear],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                }
            }

            if let goal, let start = columns.first?.index, let end = columns.last?.index {
                LineMark(
                    x: .value("index", start),
                    y: .value("distance", goal.converted(to: .primaryUnit()).value),
                    series: .value("goal", "b")
                )
                .foregroundStyle(tint)

                LineMark(
                    x: .value("index", end),
                    y: .value("distance", goal.converted(to: .primaryUnit()).value),
                    series: .value("goal", "b")
                )
                .foregroundStyle(tint)
            }
        }
        .chartScrollableAxes([.horizontal])
        .chartXVisibleDomain(length: visibleColumnCount)
        .chartLegend(.hidden)
        .chartXAxis {
            AxisMarks { value in
                if let stringValue = value.as(String.self) {
                    if let index = Int(stringValue), columns.indices.contains(index) {
                        AxisValueLabel(columns[index].label)
                    }
                }
            }
        }
        .chartForegroundStyleScale(
            mapping: { (plottableValue: String) -> Color in
                let matchingIndex = columns.compactMap { column -> Int? in
                    guard let matchingRunIndex = column.runs.firstIndex(where: { $0.id.uuidString == plottableValue }) else { return nil }
                    return matchingRunIndex
                }

                let colors: [Color] = [tint, tint.opacity(0.7)]
                return colors[(matchingIndex.first ?? 0) % colors.count]
            }
        )
    }
}

#Preview {
    GoalChartView(
        period: .weekly,
        runs: .week,
        goal: .init(value: 40, unit: .kilometers)
    )
    .customTint(.green)
    .previewDisplayName("Weekly")
}

#Preview {
    GoalChartView(
        period: .monthly,
        runs: .month,
        goal: .init(value: 150, unit: .kilometers)
    )
    .previewDisplayName("Monthly")
}

#Preview {
    GoalChartView(
        period: .yearly,
        runs: .year,
        goal: .init(value: 1250, unit: .kilometers)
    )
    .previewDisplayName("Yearly")
}
