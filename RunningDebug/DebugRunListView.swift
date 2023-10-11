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
            case cancelButtonTapped
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
            return .run { send in
//                for try await run in healthKitRunningWorkouts._runningWorkouts() {
//                    print(run.uuid, run.stats(for: .init(.distanceWalkingRunning))?.sumQuantity()?.doubleValue(for: .meter()) as Any)
                ////                    await send(._internal(.runFetched(run)))
//                }
                let result = await TaskResult {
                    try await runningWorkouts.allRunningWorkouts.remote()
                }
                await send(._internal(.runsFetched(result)))
            }
            .cancellable(id: "test_cancellation")
        case .cancelButtonTapped:
            return .cancel(id: "test_cancellation")
        }
    }

    private func _internal(_ action: Action.Internal, state: inout State) -> EffectOf<Self> {
        switch action {
        case let .runsFetched(.success(runs)):
            state.runs = .init(
                uniqueElements: runs
                    .map { DebugRunListItemFeature.State(run: $0) }
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
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Cancel") { store.send(.view(.cancelButtonTapped)) }
            }
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
