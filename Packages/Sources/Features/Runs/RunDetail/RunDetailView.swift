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
            VStack {
                Text(viewStore.run.distance.formatted())

                if viewStore.isLoading {
                    ProgressView()
                        .progressViewStyle(.circular)
                }

                Spacer()
            }
            .onAppear { viewStore.send(.onAppear) }
            .navigationTitle("Run")
        }
    }
}

#Preview("Loading") {
    let run: Run = .mock(detail: nil)
    return NavigationStack {
        RunDetailView(
            store: .init(
                initialState: .init(run: run),
                reducer: RunDetailFeature.init,
                withDependencies: {
                    $0.repository.runningWorkouts._runDetail = { _ in
                        try await Task.sleep(for: .seconds(1))
                        return run
                    }
                }
            )
        )
    }
}

#Preview("Detail Already Fetched") {
    let run: Run = .mock(detail: .mock())
    return NavigationStack {
        RunDetailView(
            store: .init(
                initialState: .init(run: run),
                reducer: RunDetailFeature.init,
                withDependencies: {
                    $0.repository.runningWorkouts._runDetail = { _ in
                        try await Task.sleep(for: .seconds(1))
                        return run
                    }
                }
            )
        )
    }
}
