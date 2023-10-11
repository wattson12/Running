import ComposableArchitecture
import HealthKit
import Model
import SwiftUI

struct DebugRunListItemFeature: Reducer {
    struct State: Equatable, Identifiable {
        let run: Run

        var id: Run.ID {
            run.id
        }
    }

    enum Action: Equatable {
        enum View: Equatable {
            case onAppear
            case tapped
        }

        case view(View)
    }

    @Dependency(\.healthKit.runningWorkouts) var runningWorkouts

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .view(action):
                return view(action, state: &state)
            }
        }
    }

    private func view(_ action: Action.View, state: inout State) -> EffectOf<Self> {
        switch action {
        case .onAppear:
            return .none
        case .tapped:
            return .run { [id = state.run.id] _ in
                try await runningWorkouts._detail(id)
            }
        }
    }
}

struct DebugRunListItemView: View {
    let store: StoreOf<DebugRunListItemFeature>

    var body: some View {
        WithViewStore(
            store,
            observe: \.run,
            send: DebugRunListItemFeature.Action.view
        ) { viewStore in
            Button(
                action: {
                    viewStore.send(.tapped)
                },
                label: {
                    Text(viewStore.distance.formatted())
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
