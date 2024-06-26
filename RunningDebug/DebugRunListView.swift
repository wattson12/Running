import ComposableArchitecture
import HealthKitServiceInterface
import Model
import Repository
import SwiftUI

@Reducer
struct DebugRunListFeature: Reducer {
    @ObservableState
    struct State: Equatable {
        var runs: IdentifiedArrayOf<DebugRunListItemFeature.State> = []
    }

    @CasePathable
    enum Action: Equatable, ViewAction {
        @CasePathable
        enum View: Equatable {
            case onAppear
            case cancelButtonTapped
        }

        @CasePathable
        enum Internal: Equatable {
            case runsFetched(TaskResult<[Run]>)
            case runFetched(Run)
        }

        case view(View)
        case runs(IdentifiedActionOf<DebugRunListItemFeature>)
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
        .forEach(\.runs, action: \.runs, element: DebugRunListItemFeature.init)
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

@ViewAction(for: DebugRunListFeature.self)
struct DebugRunListView: View {
    let store: StoreOf<DebugRunListFeature>

    var body: some View {
        List {
            ForEach(
                store.scope(state: \.runs, action: \.runs),
                id: \.state.id
            ) { store in
                DebugRunListItemView(store: store)
            }
        }
        .onAppear { send(.onAppear) }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Cancel") { send(.cancelButtonTapped) }
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
