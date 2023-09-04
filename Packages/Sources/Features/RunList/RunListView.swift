import ComposableArchitecture
import Model
import Resources
import SwiftUI

public struct RunListView: View {
    struct ViewState: Equatable {
        let sections: [RunSection]
        let isLoading: Bool
        let isInitialImport: Bool

        init(state: RunListFeature.State) {
            sections = state.sections
            isLoading = state.isLoading
            isInitialImport = state.isInitialImport
        }
    }

    let store: StoreOf<RunListFeature>

    @Environment(\.locale) var locale

    public init(
        store: StoreOf<RunListFeature>
    ) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(
            store,
            observe: ViewState.init,
            send: RunListFeature.Action.view
        ) { viewStore in
            VStack {
                if !viewStore.sections.isEmpty {
                    List {
                        ForEach(viewStore.sections) { section in
                            Section(
                                content: {
                                    ForEach(section.runs) { run in
                                        RunListItemView(run: run)
                                    }
                                },
                                header: {
                                    HStack {
                                        Text(section.title)
                                            .font(.title2)
                                            .foregroundColor(.primary)
                                            .textCase(nil)

                                        Spacer()

                                        if section.runs.count > 1 {
                                            Text(section.distance.fullValue(locale: locale))
                                                .font(.caption2)
                                                .foregroundColor(.secondary)
                                                .textCase(nil)
                                        }
                                    }
                                }
                            )
                        }
                    }
                } else if viewStore.isInitialImport {
                    InitialImportView()
                } else if !viewStore.isLoading {
                    EmptyView()
                }
            }
            .onAppear { viewStore.send(.onAppear) }
            .navigationTitle(L10n.App.Feature.runs)
            .toolbar {
                if viewStore.isLoading {
                    ToolbarItem(placement: .topBarTrailing) {
                        ProgressView()
                            .progressViewStyle(.circular)
                    }
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
