import ComposableArchitecture
import Model
import Repository
import SwiftUI

public struct RunDetailView: View {
    let store: StoreOf<RunDetailFeature>

    public init(
        store: StoreOf<RunDetailFeature>
    ) {
        self.store = store
    }

    public var body: some View {
        VStack {
            Text(store.run.distance.formatted())

            if let locations = store.run.detail?.locations {
                RouteView(locations: locations)
                    .frame(height: 200)
            }

            if store.isLoading {
                ProgressView()
                    .progressViewStyle(.circular)
            }

            Spacer()
        }
        .onAppear { store.send(.view(.onAppear)) }
        .navigationTitle("Run")
    }
}

#Preview("Loading") {
    let run: Run = .mock(detail: nil)
    var runWithDetail = run
    runWithDetail.detail = .mock(locations: .loop)
    return NavigationStack {
        RunDetailView(
            store: .init(
                initialState: .init(run: run),
                reducer: RunDetailFeature.init,
                withDependencies: {
                    $0.repository.runningWorkouts._runDetail = { [runWithDetail] _ in
                        try await Task.sleep(for: .seconds(1))
                        return runWithDetail
                    }
                }
            )
        )
    }
}

#Preview("Detail Already Fetched") {
    let run: Run = .mock(detail: .mock(locations: .loop))
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
