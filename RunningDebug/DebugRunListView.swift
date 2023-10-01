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

        case view(View)
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .view(action):
                return view(action, state: &state)
            }
        }
    }

    private func view(_ action: Action.View, state _: inout State) -> EffectOf<Self> {
        switch action {
        case .onAppear:
            return .none
        }
    }
}

struct DebugRunListView: View {
    let store: StoreOf<DebugRunListFeature>

    var body: some View {
        Text("Placeholder Run List View")
    }
}

#Preview {
    DebugRunListView(
        store: .init(
            initialState: .init(),
            reducer: DebugRunListFeature.init
        )
    )
}
