import ComposableArchitecture
import Model
import SwiftUI

public struct RunDetailFeature: Reducer {
    public struct State: Equatable {
        let run: Run
    }

    public enum Action: Equatable {
        public enum View: Equatable {}

        case view(View)
    }

    public var body: some ReducerOf<Self> {
        EmptyReducer()
    }
}

public struct RunDetailView: View {
    struct ViewState: Equatable {
        let run: Run

        init(state: RunDetailFeature.State) {
            run = state.run
        }
    }

    let store: StoreOf<RunDetailFeature>

    public init(
        store: StoreOf<RunDetailFeature>
    ) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(
            store,
            observe: ViewState.init,
            send: RunDetailFeature.Action.view
        ) { viewStore in
            Text("Placeholder Run Detail View")
            Text(viewStore.run.distance.formatted())
        }
    }
}

#Preview {
    RunDetailView(
        store: .init(
            initialState: .init(
                run: .mock()
            ),
            reducer: RunDetailFeature.init
        )
    )
}
