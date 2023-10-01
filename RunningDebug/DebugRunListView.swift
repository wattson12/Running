import ComposableArchitecture
import Model
import Repository
import SwiftUI

struct DebugRunListFeature: Reducer {
    struct State: Equatable {
        var runs: IdentifiedArrayOf<Run> = []
    }

    enum Action: Equatable {
        enum View: Equatable {
            case onAppear
        }

        enum Internal: Equatable {
            case runsFetched(TaskResult<[Run]>)
        }

        case view(View)
        case _internal(Internal)
    }

    @Dependency(\.repository.runningWorkouts) var runningWorkouts

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .view(action):
                return view(action, state: &state)
            case let ._internal(action):
                return _internal(action, state: &state)
            }
        }
    }

    private func view(_ action: Action.View, state _: inout State) -> EffectOf<Self> {
        switch action {
        case .onAppear:
            return .run { send in
                let result = await TaskResult {
                    try await runningWorkouts.allRunningWorkouts.remote()
                }
                await send(._internal(.runsFetched(result)))
            }
        }
    }

    private func _internal(_ action: Action.Internal, state: inout State) -> EffectOf<Self> {
        switch action {
        case let .runsFetched(.success(runs)):
            state.runs = .init(uniqueElements: runs)
            return .none
        case let .runsFetched(.failure(error)):
            print(error)
            return .none
        }
    }
}

struct DebugRunListView: View {
    let store: StoreOf<DebugRunListFeature>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            List(viewStore.runs) { run in
                Text(run.distance.formatted())
            }
            .onAppear { viewStore.send(.view(.onAppear)) }
        }
    }
}

#Preview {
    NavigationStack {
        DebugRunListView(
            store: .init(
                initialState: .init(),
                reducer: DebugRunListFeature.init
            )
        )
        .navigationTitle("Debug")
    }
}
