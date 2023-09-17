import ComposableArchitecture
import DesignSystem
import EditGoal
import GoalDetail
import Model
import Repository
import Resources
import SwiftUI

public struct GoalListView: View {
    struct ViewState: Equatable {
        struct GoalRow: Identifiable, Equatable {
            let goal: Goal
            let distance: Measurement<UnitLength>

            var id: String {
                goal.period.rawValue
            }
        }

        let rows: [GoalRow]

        init(state: GoalListFeature.State) {
            let weekly: (Goal?, Measurement<UnitLength>) = (
                state.weeklyGoal,
                state.weeklyRuns.map(\.distance)
                    .reduce(.init(value: 0, unit: .secondaryUnit()), +)
            )
            let monthly: (Goal?, Measurement<UnitLength>) = (
                state.monthlyGoal,
                state.monthlyRuns.map(\.distance)
                    .reduce(.init(value: 0, unit: .secondaryUnit()), +)
            )
            let yearly: (Goal?, Measurement<UnitLength>) = (
                state.yearlyGoal,
                state.yearlyRuns.map(\.distance)
                    .reduce(.init(value: 0, unit: .secondaryUnit()), +)
            )

            rows = [weekly, monthly, yearly].compactMap { goal, distance in
                guard let goal else { return nil }
                return .init(
                    goal: goal,
                    distance: distance
                )
            }
        }
    }

    let store: StoreOf<GoalListFeature>

    public init(
        store: StoreOf<GoalListFeature>
    ) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(
            store,
            observe: ViewState.init,
            send: GoalListFeature.Action.view
        ) { viewStore in
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(viewStore.rows) { row in
                        GoalRowView(
                            goal: row.goal,
                            distance: row.distance,
                            action: {
                                viewStore.send(.goalTapped(row.goal))
                            },
                            editAction: {
                                viewStore.send(.editTapped(row.goal))
                            }
                        )
                        .customTint(row.goal.period.tint)
                    }
                }
            }
            .navigationTitle(L10n.App.Feature.goals)
            .onAppear { viewStore.send(.onAppear) }
            .navigationDestination(
                store: store.scope(
                    state: \.$destination,
                    action: GoalListFeature.Action.destination
                ),
                state: /GoalListFeature.Destination.State.detail,
                action: GoalListFeature.Destination.Action.detail,
                destination: GoalDetailView.init
            )
            .sheet(
                store: store.scope(
                    state: \.$destination,
                    action: GoalListFeature.Action.destination
                ),
                state: /GoalListFeature.Destination.State.editGoal,
                action: GoalListFeature.Destination.Action.editGoal,
                content: { store in
                    EditGoalView(store: store)
                        .presentationDetents([.medium])
                }
            )
        }
    }
}

struct UpdatedGoalPreviewWrapperFeature: Reducer {
    struct State: Equatable {
        var goalList: GoalListFeature.State
    }
    
    enum Action: Equatable {
        enum View: Equatable {
            case onAppear
        }
        
        enum Internal: Equatable {
            case refreshGoals
        }
        
        case view(View)
        case _internal(Internal)
        case goalList(GoalListFeature.Action)
    }
    
    @Dependency(\.mainQueue) var mainQueue
    @Dependency(\.repository.goals) var goals
    @Dependency(\.repository.runningWorkouts) var runningWorkouts
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .view(action):
                return view(action, state: &state)
            case let ._internal(action):
                return _internal(action, state: &state)
            case .goalList:
                return .none
            }
        }
        Scope(state: \.goalList, action: /Action.goalList, child: GoalListFeature.init)
    }
    
    private func view(_ action: Action.View, state: inout State) -> EffectOf<Self> {
        switch action {
        case .onAppear:
            return .run { send in
                try await mainQueue.sleep(for: .seconds(2))
                await send(._internal(.refreshGoals))
            }
        }
    }
    
    private func _internal(_ action: Action.Internal, state: inout State) -> EffectOf<Self> {
        switch action {
        case .refreshGoals:
            state.goalList.refresh(goals: goals, runningWorkouts: runningWorkouts)
            return .none
        }
    }
}

struct UpdatedGoalPreviewWrapper: View {
    let store: StoreOf<UpdatedGoalPreviewWrapperFeature>
    
    var body: some View {
        GoalListView(
            store: store.scope(
                state: \.goalList,
                action: UpdatedGoalPreviewWrapperFeature.Action.goalList
            )
        )
        .onAppear { store.send(.view(.onAppear)) }
    }
}

struct GoalListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            GoalListView(
                store: .init(
                    initialState: .init(),
                    reducer: GoalListFeature.init,
                    withDependencies: {
                        $0.date = .constant(.preview)
                        $0.locale = .init(identifier: "en_AU")
                    }
                )
            )
        }
        .environment(\.locale, .init(identifier: "en_AU"))

        let test: LockIsolated<Int> = .init(0)

        NavigationStack {
            UpdatedGoalPreviewWrapper(
                store: .init(
                    initialState: .init(goalList: .init()),
                    reducer: UpdatedGoalPreviewWrapperFeature.init,
                    withDependencies: {
                        $0.date = .constant(.preview)
                        $0.locale = .init(identifier: "en_AU")

                        $0.repository.runningWorkouts._runsWithinGoal = { goal in
                            guard goal.period == .yearly else { return [] }
                            test.withValue { $0 += 1 }

                            if test.value == 1 {
                                return [
                                    .mock(
                                        distance: .init(value: 100, unit: .kilometers)
                                    ),
                                ]
                            } else {
                                return [
                                    .mock(
                                        distance: .init(value: 500, unit: .kilometers)
                                    ),
                                    .mock(
                                        distance: .init(value: 500, unit: .kilometers)
                                    ),
                                ]
                            }
                        }

                        $0.repository.runningWorkouts._allRunningWorkouts = {
                            .mock(value: [], delay: 2)
                        }
                    }
                )
            )
        }
        .environment(\.locale, .init(identifier: "en_AU"))
        .previewDisplayName("Updated Goal")
    }
}
