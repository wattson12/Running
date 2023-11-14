import ComposableArchitecture
import Foundation
import Repository
import SwiftUI

@Reducer
struct UpdatedGoalPreviewWrapperFeature {
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

    private func view(_ action: Action.View, state _: inout State) -> EffectOf<Self> {
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
