import ComposableArchitecture
import DesignSystem
import Model
import Repository
import Resources
import SwiftUI

@ViewAction(for: RunDetailFeature.self)
public struct RunDetailView: View {
    public let store: StoreOf<RunDetailFeature>

    @Environment(\.locale) var locale

    public init(
        store: StoreOf<RunDetailFeature>
    ) {
        self.store = store
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                if let locations = store.run.detail?.locations, !locations.isEmpty {
                    IconBorderedView(
                        image: .init(systemName: "map.circle"),
                        title: L10n.Runs.Detail.Section.route
                    ) {
                        RouteView(locations: locations)
                            .frame(height: 200)
                            .allowsHitTesting(false)
                            .cornerRadius(8)
                    }
                    .customTint(Color(asset: Asset.blue))
                } else if store.isLoading {
                    loading()
                        .customTint(Color(asset: Asset.blue))
                } else {
                    empty(
                        image: .init(systemName: "map.circle"),
                        title: L10n.Runs.Detail.Section.route,
                        message: L10n.Runs.Detail.Section.Route.empty
                    )
                    .customTint(Color(asset: Asset.blue))
                }

                if let splits = store.splits, !splits.isEmpty {
                    IconBorderedView(
                        image: .init(systemName: "stopwatch"),
                        title: L10n.Runs.Detail.Section.splits
                    ) {
                        DistanceSplitView(splits: splits)
                            .frame(height: 200)
                            .cornerRadius(8)
                    }
                    .customTint(Color(asset: Asset.green))
                } else if store.isLoading {
                    loading()
                        .customTint(Color(asset: Asset.green))
                } else {
                    empty(
                        image: .init(systemName: "stopwatch"),
                        title: L10n.Runs.Detail.Section.splits,
                        message: L10n.Runs.Detail.Section.Splits.empty
                    )
                    .customTint(Color(asset: Asset.green))
                }

                if let locations = store.run.detail?.locations, !locations.isEmpty, let splits = store.splits {
                    IconBorderedView(
                        image: .init(systemName: "mountain.2.circle"),
                        title: L10n.Runs.Detail.Section.altitude
                    ) {
                        AltitudeChartView(
                            locations: locations,
                            splits: splits
                        )
                        .frame(height: 200)
                        .cornerRadius(8)
                    }
                    .customTint(Color(asset: Asset.purple))
                } else if store.isLoading {
                    loading()
                        .customTint(Color(asset: Asset.purple))
                } else {
                    empty(
                        image: .init(systemName: "mountain.2.circle"),
                        title: L10n.Runs.Detail.Section.altitude,
                        message: L10n.Runs.Detail.Section.Altitude.empty
                    )
                    .customTint(Color(asset: Asset.purple))
                }
            }
            .padding(.horizontal, 16)
        }
        .onAppear { send(.onAppear) }
        .navigationTitle(store.run.distance.fullValue(locale: locale))
        .toolbar {
            if store.isLoading {
                ToolbarItem(placement: .topBarTrailing) {
                    ProgressView()
                        .progressViewStyle(.circular)
                }
            }
        }
    }

    @ViewBuilder func loading() -> some View {
        IconBorderedView(
            image: .init(systemName: "mountain.2.circle"),
            title: "Loading"
        ) {
            Color.gray.opacity(0.3)
                .frame(height: 200)
                .cornerRadius(8)
        }
        .redacted(reason: .placeholder)
    }

    @ViewBuilder func empty(
        image: Image,
        title: String,
        message: String
    ) -> some View {
        IconBorderedView(
            image: image,
            title: title
        ) {
            ZStack {
                Color.gray.opacity(0.3)
                    .frame(height: 200)
                    .cornerRadius(8)

                Text(message)
                    .font(.body)
                    .padding(.all, 16)
                    .foregroundStyle(.secondary)
            }
        }
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

#Preview("Indefinite loading") {
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
                        try await Task.sleep(for: .seconds(1_000_000))
                        return runWithDetail
                    }
                }
            )
        )
    }
}

#Preview("Empty Sections") {
    let run: Run = .mock(
        detail: .mock(locations: [], distanceSamples: [])
    )
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

#Preview("Live data") {
    let run: Run = .content("long_run")
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
