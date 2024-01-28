import ComposableArchitecture
import DesignSystem
import Model
import Repository
import Resources
import RunList
import SwiftUI

public struct GoalDetailView: View {
    let store: StoreOf<GoalDetailFeature>

    @Environment(\.locale) var locale

    public init(store: StoreOf<GoalDetailFeature>) {
        self.store = store
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if
                    let runs = store.runs,
                    let target = store.goal.target
                {
                    IconBorderedView(
                        image: .init(systemName: "ruler"),
                        title: "Summary"
                    ) {
                        VStack(spacing: 8) {
                            HStack {
                                Text(L10n.Goals.Detail.Summary.goal)
                                    .font(.title3)
                                Spacer()
                                Text(target.fullValue(locale: locale))
                                    .font(.body.bold())
                            }

                            HStack {
                                Text(L10n.Goals.Detail.Summary.distance)
                                    .font(.title3)
                                Spacer()
                                Text(runs.distance.fullValue(locale: locale))
                                    .font(.body.bold())
                            }

                            if (target - runs.distance).value > 0 {
                                HStack {
                                    Text(L10n.Goals.Detail.Summary.remaining)
                                        .font(.title3)
                                    Spacer()
                                    Text((target - runs.distance).fullValue(locale: locale))
                                        .font(.body.bold())
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)

                    if !runs.isEmpty {
                        IconBorderedView(
                            image: .init(systemName: "chart.line.uptrend.xyaxis"),
                            title: "Progress"
                        ) {
                            GoalChartView(
                                period: store.goal.period,
                                runs: runs,
                                goal: target
                            )
                            .frame(height: 250)
                        }
                        .padding(.horizontal, 16)
                    } else {
                        IconBorderedView(
                            image: .init(systemName: "chart.line.uptrend.xyaxis"),
                            title: "Progress"
                        ) {
                            GoalChartView(
                                period: store.goal.period,
                                runs: store.emptyStateRuns,
                                goal: target
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
        .navigationTitle(store.title)
        .onAppear { store.send(.view(.onAppear)) }
        .customTint(store.goal.period.tint)
    }
}

struct GoalDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            GoalDetailView.preview(
                goalPeriod: .weekly
            )
        }
        .environment(\.locale, .init(identifier: "en_AU"))
        .previewDisplayName("Weekly")

        NavigationStack {
            GoalDetailView.preview(
                goalPeriod: .monthly
            )
        }
        .environment(\.locale, .init(identifier: "en_AU"))
        .previewDisplayName("Monthly")

        NavigationStack {
            GoalDetailView.preview(
                goalPeriod: .yearly
            )
        }
        .environment(\.locale, .init(identifier: "en_AU"))
        .previewDisplayName("Yearly")

        NavigationStack {
            GoalDetailView.preview(
                goalPeriod: .yearly,
                date: Date(timeIntervalSince1970: 1_578_346_222) // 2020
            )
        }
        .environment(\.locale, .init(identifier: "en_AU"))
        .previewDisplayName("Custom Date")

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
                    }
                )
            )
        }
        .environment(\.locale, .init(identifier: "en_AU"))
        .previewDisplayName("Empty")
    }
}

extension GoalDetailView {
    private static func target(from period: Goal.Period) -> Measurement<UnitLength> {
        switch period {
        case .weekly:
            return .init(value: 20, unit: .kilometers)
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
