import ComposableArchitecture
import Model
import Resources
import RunDetail
import SwiftUI

@ViewAction(for: RunListFeature.self)
public struct RunListView: View {
    @Bindable public var store: StoreOf<RunListFeature>

    @Environment(\.locale) var locale

    public init(
        store: StoreOf<RunListFeature>
    ) {
        self.store = store
    }

    public var body: some View {
        VStack {
            if !store.runs.isEmpty {
                List {
                    ForEach(store.runs) { run in
                        RunListItemView(
                            run: run,
                            tapped: {
                                send(.runTapped(run.run))
                            }
                        )
                    }
                }
                .navigationDestination(
                    item: $store.scope(
                        state: \.destination?.detail,
                        action: \.destination.detail
                    ),
                    destination: RunDetailView.init
                )
            } else if store.isInitialImport {
                InitialImportView()
            } else if !store.isLoading {
                EmptyView()
            }
        }
        .onAppear { send(.onAppear) }
        .navigationTitle(L10n.App.Feature.runs)
        .toolbar {
            if store.isLoading {
                ToolbarItem(placement: .topBarTrailing) {
                    ProgressView()
                        .progressViewStyle(.circular)
                }
            }
        }
    }
}

struct RunListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            RunListView(
                store: .init(
                    initialState: .init(),
                    reducer: RunListFeature.init,
                    withDependencies: {
                        $0.date = .constant(.preview)
                    }
                )
            )
            .environment(\.locale, .init(identifier: "en_AU"))
        }

        NavigationStack {
            RunListView(
                store: .init(
                    initialState: .init(),
                    reducer: RunListFeature.init,
                    withDependencies: {
                        $0.repository.runningWorkouts._allRunningWorkouts = { .mock(value: []) }
                    }
                )
            )
            .environment(\.locale, .init(identifier: "en_AU"))
        }
        .previewDisplayName("Empty")

        NavigationStack {
            RunListView(
                store: .init(
                    initialState: .init(),
                    reducer: RunListFeature.init,
                    withDependencies: {
                        $0.repository.runningWorkouts._allRunningWorkouts = {
                            .init(
                                cache: { nil },
                                remote: {
                                    try await Task.sleep(for: .seconds(1_000_000))
                                    return []
                                }
                            )
                        }
                    }
                )
            )
            .environment(\.locale, .init(identifier: "en_AU"))
        }
        .previewDisplayName("Initial Import")

        NavigationStack {
            RunListView(
                store: .init(
                    initialState: .init(),
                    reducer: RunListFeature.init,
                    withDependencies: {
                        $0.repository.runningWorkouts._allRunningWorkouts = {
                            .init(
                                cache: { nil },
                                remote: {
                                    try await Task.sleep(for: .seconds(2))
                                    return .allRuns
                                }
                            )
                        }
                    }
                )
            )
            .environment(\.locale, .init(identifier: "en_AU"))
        }
        .previewDisplayName("Live - Initial Import")

        NavigationStack {
            RunListView(
                store: .init(
                    initialState: .init(),
                    reducer: RunListFeature.init,
                    withDependencies: {
                        let allRunsWithoutMostRecent: [Run] = Array([Run].allRuns.dropLast())
                        $0.repository.runningWorkouts._allRunningWorkouts = {
                            .init(
                                cache: { allRunsWithoutMostRecent },
                                remote: {
                                    try await Task.sleep(for: .seconds(2))
                                    return .allRuns
                                }
                            )
                        }
                        $0.date = .constant(.preview)
                    }
                )
            )
            .environment(\.locale, .init(identifier: "en_AU"))
        }
        .previewDisplayName("Live - Update")
    }
}
