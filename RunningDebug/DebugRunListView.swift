import ComposableArchitecture
import HealthKitServiceInterface
import Model
import Repository
import SwiftUI

struct DebugRunListFeature: Reducer {
    struct State: Equatable {
        var runs: IdentifiedArrayOf<DebugRunListItemFeature.State> = []
    }

    enum Action: Equatable {
        enum View: Equatable {
            case onAppear
        }

        enum Internal: Equatable {
            case runsFetched(TaskResult<[Run]>)
            case runFetched(Run)
        }

        case view(View)
        case runs(Run.ID, DebugRunListItemFeature.Action)
        case _internal(Internal)
    }

    @Dependency(\.repository.runningWorkouts) var runningWorkouts
    @Dependency(\.healthKit.runningWorkouts) var healthKitRunningWorkouts

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .view(action):
                return view(action, state: &state)
            case .runs:
                return .none
            case let ._internal(action):
                return _internal(action, state: &state)
            }
        }
        .forEach(\.runs, action: /Action.runs, element: DebugRunListItemFeature.init)
    }

    private func view(_ action: Action.View, state _: inout State) -> EffectOf<Self> {
        switch action {
        case .onAppear:
            return .run { _ in
                for try await run in healthKitRunningWorkouts._runningWorkouts() {
                    print(run)
//                    await send(._internal(.runFetched(run)))
                }
//                let result = await TaskResult {
//                    try await runningWorkouts.allRunningWorkouts.remote()
//                }
//                await send(._internal(.runsFetched(result)))
            }
        }
    }

    private func _internal(_ action: Action.Internal, state: inout State) -> EffectOf<Self> {
        switch action {
        case let .runsFetched(.success(runs)):
            state.runs = .init(
                uniqueElements: runs
                    .map(DebugRunListItemFeature.State.init)
            )
            return .none
        case let .runsFetched(.failure(error)):
            print(error)
            return .none
        case let .runFetched(run):
            state.runs[id: run.id] = .init(run: run)
            return .none
        }
    }
}

struct DebugRunListView: View {
    let store: StoreOf<DebugRunListFeature>

    var body: some View {
        List {
            ForEachStore(
                store.scope(
                    state: \.runs,
                    action: DebugRunListFeature.Action.runs
                ),
                content: DebugRunListItemView.init
            )
        }
        .onAppear { store.send(.view(.onAppear)) }
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
