import ComposableArchitecture
import DesignSystem
import Model
import Repository
import Resources
import RunList
import SwiftUI

public struct GoalDetailView: View {
    struct ViewState: Equatable {
        let goal: Goal
        let runs: [Run]?
        let emptyStateRuns: [Run]

        init(state: GoalDetailFeature.State) {
            goal = state.goal
            runs = state.runs
            emptyStateRuns = state.emptyStateRuns
        }
    }

    let store: StoreOf<GoalDetailFeature>

    @Environment(\.locale) var locale

    public init(store: StoreOf<GoalDetailFeature>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(
            store,
            observe: ViewState.init,
            send: GoalDetailFeature.Action.view
        ) { viewStore in
            ScrollView {
                VStack(spacing: 16) {
                    if
                        let runs = viewStore.runs,
                        let target = viewStore.goal.target
                    {
                        WidgetView {
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

                        if !runs.isEmpty {
                            WidgetView {
                                GoalChartView(
                                    period: viewStore.goal.period,
                                    runs: runs,
                                    goal: target
                                )
                            }
                            .frame(height: 250)
                        } else {
                            WidgetView {
                                GoalChartView(
                                    period: viewStore.goal.period,
                                    runs: viewStore.emptyStateRuns,
                                    goal: target
                                )
                                .blur(radius: 5)
                            }
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
                    }
                }
            }
            .navigationTitle(viewStore.goal.period.rawValue.capitalized)
            .onAppear { viewStore.send(.onAppear) }
            .customTint(viewStore.goal.period.tint)
        }
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
                        $0.repository.runningWorkouts._runsWithinGoal = { _ in [] }
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
        goalPeriod: Goal.Period
    ) -> Self {
        GoalDetailView(
            store: .init(
                initialState: .init(
                    goal: Goal(
                        period: goalPeriod,
                        target: target(from: goalPeriod)
                    ),
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
