import ComposableArchitecture
import Model
import Repository
import Resources
import SwiftUI

public struct RunDetailView: View {
    let store: StoreOf<RunDetailFeature>

    @Environment(\.locale) var locale

    public init(
        store: StoreOf<RunDetailFeature>
    ) {
        self.store = store
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                if let locations = store.run.detail?.locations {
                    IconBorderedView(
                        tint: Color(Asset.blue.color),
                        image: .init(systemName: "map.circle")
                    ) {
                        RouteView(locations: locations)
                            .frame(height: 200)
                            .allowsHitTesting(false)
                            .cornerRadius(8)
                    }
                }

                if let splits = store.splits {
                    IconBorderedView(
                        tint: Color(Asset.green.color),
                        image: .init(systemName: "stopwatch")
                    ) {
                        DistanceSplitView(splits: splits)
                            .frame(height: 200)
                            .cornerRadius(8)
                    }
                }

                if let locations = store.run.detail?.locations, let splits = store.splits {
                    IconBorderedView(
                        tint: Color(Asset.purple.color),
                        image: .init(systemName: "mountain.2.circle")
                    ) {
                        AltitudeChartView(
                            locations: locations,
                            splits: splits
                        )
                        .frame(height: 200)
                        .allowsHitTesting(false)
                        .cornerRadius(8)
                    }
                }

                if store.isLoading {
                    ProgressView()
                        .progressViewStyle(.circular)
                }

                Spacer()
            }
            .padding(.horizontal, 16)
        }
        .onAppear { store.send(.view(.onAppear)) }
        .navigationTitle(store.run.distance.fullValue(locale: locale))
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
                    $0.locale = .init(identifier: "en_AU")
                }
            )
        )
        .environment(\.locale, .init(identifier: "en_AU"))
    }
}
