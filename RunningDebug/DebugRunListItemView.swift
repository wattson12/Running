import ComposableArchitecture
import HealthKit
import HealthKitServiceInterface
import Model
import SwiftUI

struct DebugRunListItemFeature: Reducer {
    struct State: Equatable, Identifiable {
        let run: Run
        var isLoading: Bool = false

        var id: Run.ID {
            run.id
        }
    }

    enum Action: Equatable {
        enum View: Equatable {
            case onAppear
            case tapped
        }

        enum Internal: Equatable {
            case detailFetched(TaskResult<WorkoutDetail>)
        }

        case view(View)
        case _internal(Internal)
    }

    @Dependency(\.healthKit.runningWorkouts) var runningWorkouts

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

    private func view(_ action: Action.View, state: inout State) -> EffectOf<Self> {
        switch action {
        case .onAppear:
            return .none
        case .tapped:
            state.isLoading = true
            return .run { [id = state.run.id] send in
                let result = await TaskResult {
                    try await runningWorkouts.detail(for: id)
                }
                await send(._internal(.detailFetched(result)))
            }
        }
    }

    private func _internal(_ action: Action.Internal, state: inout State) -> EffectOf<Self> {
        switch action {
        case let .detailFetched(.success(detail)):
            state.isLoading = false
            print(detail.locations.count)
            print(detail.samples.count)
            return .none
        case let .detailFetched(.failure(error)):
            state.isLoading = false
            print(error)
            return .none
        }
    }
}

struct DebugRunListItemView: View {
    let store: StoreOf<DebugRunListItemFeature>

    var body: some View {
        WithViewStore(
            store,
            observe: { $0 },
            send: DebugRunListItemFeature.Action.view
        ) { viewStore in
            Button(
                action: {
                    viewStore.send(.tapped)
                },
                label: {
                    HStack {
                        Text(viewStore.run.distance.formatted())
                        Spacer()
                        if viewStore.isLoading {
                            ProgressView()
                                .progressViewStyle(.circular)
                        }
                    }
                    .contentShape(Rectangle())
                }
            )
            .onAppear { viewStore.send(.onAppear) }
        }
    }
}

#Preview {
    DebugRunListItemView(
        store: .init(
            initialState: .init(run: .mock()),
            reducer: DebugRunListItemFeature.init
        )
    )
}
