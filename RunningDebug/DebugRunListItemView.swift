import ComposableArchitecture
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
        }

        case view(View)
    }

    var body: some ReducerOf<Self> {
        EmptyReducer()
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
            Text(viewStore.distance.formatted())
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
