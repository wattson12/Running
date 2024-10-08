import ComposableArchitecture
import DesignSystem
import GoalHistory
import Model
import Repository
import Resources
import RunList
import SwiftUI

@ViewAction(for: GoalDetailFeature.self)
public struct GoalDetailView: View {
    @Bindable public var store: StoreOf<GoalDetailFeature>

    @Environment(\.locale) var locale

    public init(store: StoreOf<GoalDetailFeature>) {
        self.store = store
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if let runs = store.runs {
                    IconBorderedView(
                        image: .init(systemName: "ruler"),
                        title: L10n.Goals.Detail.Summary.title
                    ) {
                        VStack(spacing: 8) {
                            HStack {
                                Text(L10n.Goals.Detail.Summary.goal)
                                    .font(.title3)
                                Spacer()
                                if let target = store.goal.target {
                                    Text(target.fullValue(locale: locale))
                                        .font(.body.bold())
                                } else {
                                    Text("-")
                                }
                            }

                            HStack {
                                Text(L10n.Goals.Detail.Summary.distance)
                                    .font(.title3)
                                Spacer()
                                Text(runs.distance.fullValue(locale: locale))
                                    .font(.body.bold())
                            }

                            if let target = store.goal.target, (target - runs.distance).value > 0 {
                                HStack {
                                    Text(L10n.Goals.Detail.Summary.remaining)
                                        .font(.title3)
                                    Spacer()
                                    Text((target - runs.distance).fullValue(locale: locale))
                                        .font(.body.bold())
                                }
                            }

                            HStack {
                                Text("Runs")
                                    .font(.title3)
                                Spacer()
                                Text(runs.count.description)
                                    .font(.body.bold())
                            }

                            if let averageDistance = store.averageDistance {
                                HStack {
                                    Text("Average Distance")
                                        .font(.title3)
                                    Spacer()
                                    Text(averageDistance.fullValue(locale: locale))
                                        .font(.body.bold())
                                }
                            }

                            if let totalDuration = store.totalDuration {
                                HStack {
                                    Text("Total Duration")
                                        .font(.title3)
                                    Spacer()
                                    Text(totalDuration.fullValue(locale: locale))
                                        .font(.body.bold())
                                }
                            }

                            if let averageDuration = store.averageDuration {
                                HStack {
                                    Text("Average Duration")
                                        .font(.title3)
                                    Spacer()
                                    Text(averageDuration.fullValue(locale: locale))
                                        .font(.body.bold())
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)

                    if !runs.isEmpty {
                        IconBorderedView(
                            image: .init(systemName: "chart.line.uptrend.xyaxis"),
                            title: L10n.Goals.Detail.Progress.title
                        ) {
                            GoalChartView(
                                store: store,
                                runs: runs
                            )
                            .frame(height: 250)
                        }
                        .padding(.horizontal, 16)
                    } else {
                        IconBorderedView(
                            image: .init(systemName: "chart.line.uptrend.xyaxis"),
                            title: L10n.Goals.Detail.Progress.title
                        ) {
                            GoalChartView(
                                store: store,
                                runs: store.emptyStateRuns
                            )
                            .blur(radius: 5)
                            .frame(height: 250)
                            .overlay {
                                VStack {
                                    Image(systemName: "xmark.circle.fill")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(height: 20)

                                    Text(L10n.Goals.Detail.Chart.noRunsOverlay)
                                        .font(.callout)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                }
            }
        }
        .toolbar {
            if store.goalHistoryEnabled {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(
                        action: { send(.historyButtonTapped) },
                        label: { Image(systemName: "clock.arrow.circlepath") }
                    )
                }
            }
        }
        .sheet(
            item: $store.scope(
                state: \.destination?.history,
                action: \.destination.history
            ),
            content: { goalHistoryStore in
                NavigationStack {
                    GoalHistoryView(store: goalHistoryStore)
                }
            }
        )
        .navigationTitle(store.title)
        .onAppear { send(.onAppear) }
        .customTint(store.goal.period.tint)
    }
}

#Preview("Weekly") {
    NavigationStack {
        GoalDetailView.preview(
            goalPeriod: .weekly
        )
    }
    .environment(\.locale, .init(identifier: "en_AU"))
}

#Preview("Monthly") {
    NavigationStack {
        GoalDetailView.preview(
            goalPeriod: .monthly
        )
    }
    .environment(\.locale, .init(identifier: "en_AU"))
}

#Preview("Yearly") {
    NavigationStack {
        GoalDetailView.preview(
            goalPeriod: .yearly
        )
    }
    .environment(\.locale, .init(identifier: "en_AU"))
}

#Preview("Custom Date") {
    NavigationStack {
        GoalDetailView.preview(
            goalPeriod: .yearly,
            date: Date(timeIntervalSince1970: 1_578_346_222) // 2020
        )
    }
    .environment(\.locale, .init(identifier: "en_AU"))
}

#Preview("Empty") {
    NavigationStack {
        GoalDetailView(
            store: .init(
                initialState: .init(
                    goal: Goal(
                        period: .monthly,
                        target: .init(
                            value: 20,
                            unit: .kilometers
                        )
                    ),
                    runs: []
                ),
                reducer: GoalDetailFeature.init,
                withDependencies: {
                    $0.date = .constant(.preview)
                    $0.repository.runningWorkouts._allRunningWorkouts = { .mock(value: []) }
                    $0.repository.runningWorkouts._runsWithinGoal = { _, _ in [] }
                }
            )
        )
    }
    .environment(\.locale, .init(identifier: "en_AU"))
}

extension GoalDetailView {
    private static func target(from period: Goal.Period) -> Measurement<UnitLength> {
        switch period {
        case .weekly:
            return .init(value: 120, unit: .kilometers)
        case .monthly:
            return .init(value: 100, unit: .kilometers)
        case .yearly:
            return .init(value: 1000, unit: .kilometers)
        }
    }

    static func preview(
        goalPeriod: Goal.Period,
        date: Date? = nil
    ) -> Self {
        GoalDetailView(
            store: .init(
                initialState: .init(
                    goal: Goal(
                        period: goalPeriod,
                        target: target(from: goalPeriod)
                    ),
                    intervalDate: date,
                    runs: .week
                ),
                reducer: GoalDetailFeature.init,
                withDependencies: {
                    $0.date = .constant(.preview)
                }
            )
        )
    }

    static func empty(
        period: Goal.Period
    ) -> Self {
        GoalDetailView(
            store: .init(
                initialState: .init(
                    goal: Goal(
                        period: period,
                        target: target(from: period)
                    ),
                    runs: []
                ),
                reducer: GoalDetailFeature.init,
                withDependencies: {
                    $0.repository.runningWorkouts._allRunningWorkouts = { .mock(value: []) }
                    $0.date = .constant(.preview)
                }
            )
        )
    }
}
