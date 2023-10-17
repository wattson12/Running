import ComposableArchitecture
import Model
import Repository
import SwiftUI

public struct RunDetailView: View {
    struct ViewState: Equatable {
        let run: Run
        let isLoading: Bool

        init(state: RunDetailFeature.State) {
            run = state.run
            isLoading = state.isLoading
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

            if viewStore.isLoading {
                ProgressView()
                    .progressViewStyle(.circular)
            }
        }
    }
}

#Preview {
    RunDetailView(
        store: .init(
            initialState: .init(
                run: .mock()
            ),
            reducer: RunDetailFeature.init,
            withDependencies: {
                $0.repository.runningWorkouts._runDetail = { _ in
                    try await Task.sleep(for: .seconds(1))
                    return .mock()
                }
            }
        )
    )
}
