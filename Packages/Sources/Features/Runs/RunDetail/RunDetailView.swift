import ComposableArchitecture
import Model
import Repository
import SwiftUI

struct ContentView<Content: View>: View {
    let tint: Color
    let image: Image
    let content: () -> Content

    var body: some View {
        ZStack(alignment: .topLeading) {
            Color.clear
                .clipShape(RoundedRectangle(cornerSize: .init(width: 6, height: 6)))
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(tint, lineWidth: 2)
                        .padding(.top, 10)
                )

            HStack {
                Spacer().frame(width: 16)
                image
                    .foregroundStyle(tint)
                    .padding(.horizontal, 2)
                    .background(Color.white)
                Spacer()
            }

            content()
                .cornerRadius(6)
                .padding(.top, 12)
                .padding(/*@START_MENU_TOKEN@*/ .all/*@END_MENU_TOKEN@*/, 8)
        }
        .fixedSize(horizontal: false, vertical: true)
    }
}

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
                    ContentView(tint: .red, image: .init(systemName: "map.circle")) {
                        RouteView(locations: locations)
                            .frame(height: 200)
                            .allowsHitTesting(false)
                            .cornerRadius(8)
                    }
                }

                if let splits = store.splits {
                    ContentView(tint: .red, image: .init(systemName: "stopwatch")) {
                        DistanceSplitView(splits: splits)
                            .frame(height: 200)
                            .cornerRadius(8)
                    }
                }

                if let locations = store.run.detail?.locations, let splits = store.splits {
                    ContentView(tint: .red, image: .init(systemName: "mountain.2.circle")) {
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
