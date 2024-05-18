import Charts
import ComposableArchitecture
import DesignSystem
import Model
import Resources
import SwiftUI

@ViewAction(for: GoalDetailFeature.self)
struct GoalChartView: View {
    @Bindable public var store: StoreOf<GoalDetailFeature>
    let columns: [ChartColumn]
    @State var displayColumnData: [Bool]
    let visibleColumnCount: Int
    @Environment(\.tintColor) var tint

    init(
        store: StoreOf<GoalDetailFeature>,
        runs: [Run]
    ) {
        self.store = store

        let columns: [ChartColumn]
        switch store.goal.period {
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
        self.columns = columns

        displayColumnData = .init(repeating: !store.allowAnimation, count: columns.count)
    }

    var body: some View {
        VStack {
            Chart {
                ForEach(
                    Array(columns.enumerated()),
                    id: \.element.id
                ) { index, column in
                    if !column.runs.isEmpty {
                        ForEach(column.runs) { run in
                            BarMark(
                                x: .value("index", column.index),
                                yStart: .value("distance", displayColumnData[index] ? run.start.converted(to: .primaryUnit()).value : 0),
                                yEnd: .value("distance", displayColumnData[index] ? run.end.converted(to: .primaryUnit()).value : 0)
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
                            y: .value("distance", displayColumnData[index] ? column.cumulativeDistance.converted(to: .primaryUnit()).value : 0)
                        )
                        .foregroundStyle(tint)
                        .interpolationMethod(.monotone)

                        AreaMark(
                            x: .value("index", column.index),
                            y: .value("distance", displayColumnData[index] ? column.cumulativeDistance.converted(to: .primaryUnit()).value : 0)
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

                if let goal = store.goal.target, store.showTarget, let start = columns.first?.index, let end = columns.last?.index {
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
            .chartYScale(domain: distanceRange)
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

            if store.goal.target != nil {
                HStack {
                    Spacer()
                    ChartButton(
                        title: L10n.Goals.Detail.Chart.targetButton,
                        symbol: "target",
                        selected: $store.showTarget
                    )
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 4)
            }
        }
        .task {
            // short delay to allow for push
            try? await Task.sleep(for: .seconds(0.25))

            guard store.allowAnimation else { return }
            send(.animationShown)

            // animate each column with slightly longer delay
            for index in 0 ..< columns.count {
                withAnimation(
                    .interpolatingSpring(stiffness: 150, damping: 10)
                        .delay(Double(index + 1) * 1 / Double(columns.count))
                ) {
                    displayColumnData[index] = true
                }
            }
        }
    }

    var distanceRange: ClosedRange<Int> {
        let min = 0
        let maxValue: Int
        let goalValue: Int
        if store.showTarget, let goal = store.goal.target?.converted(to: .primaryUnit()) {
            goalValue = Int(ceil(goal.value))
        } else {
            goalValue = store.showTarget ? 0 : 20
        }

        if let cumulativeDistance = columns.last?.cumulativeDistance {
            maxValue = max(goalValue, Int(cumulativeDistance.converted(to: .primaryUnit()).value))
        } else {
            maxValue = goalValue
        }
        return min ... (maxValue + 10)
    }
}

#Preview("Weekly") {
    GoalChartView(
        store: .init(
            initialState: GoalDetailFeature.State(
                goal: .mock(
                    period: .weekly,
                    target: .init(value: 140, unit: .kilometers)
                ),
                showTarget: true
            ),
            reducer: GoalDetailFeature.init
        ),
        runs: .week
    )
    .customTint(.green)
}

#Preview("Weekly (No goal)") {
    GoalChartView(
        store: .init(
            initialState: GoalDetailFeature.State(
                goal: .mock(
                    period: .weekly,
                    target: nil
                ),
                showTarget: true
            ),
            reducer: GoalDetailFeature.init
        ),
        runs: .week
    )
    .customTint(.green)
}

#Preview("Monthly") {
    GoalChartView(
        store: .init(
            initialState: GoalDetailFeature.State(
                goal: .mock(
                    period: .monthly,
                    target: .init(value: 150, unit: .kilometers)
                ),
                showTarget: true
            ),
            reducer: GoalDetailFeature.init
        ),
        runs: .month
    )
}

#Preview("Yearly") {
    GoalChartView(
        store: .init(
            initialState: GoalDetailFeature.State(
                goal: .mock(
                    period: .yearly,
                    target: .init(value: 1250, unit: .kilometers)
                ),
                showTarget: true
            ),
            reducer: GoalDetailFeature.init
        ),
        runs: .year
    )
}
