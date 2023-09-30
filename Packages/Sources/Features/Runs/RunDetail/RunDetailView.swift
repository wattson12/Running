import ComposableArchitecture
import Model
import SwiftUI

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
