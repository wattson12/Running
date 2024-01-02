import ComposableArchitecture
import DesignSystem
import GoalList
import History
import Model
import Permissions
import Repository
import Resources
import RunList
import Settings
import SwiftUI

public struct AppView: View {
    @State var store: StoreOf<AppFeature>

    public init(store: StoreOf<AppFeature>) {
        _store = .init(initialValue: store)
    }

    public var body: some View {
        if let permissionStore = store.scope(state: \.permissions, action: \.permissions) {
            PermissionsView(store: permissionStore)
        } else {
            TabView(
                selection: $store.tab.sending(\.view.updateTab)
            ) {
                NavigationStack {
                    GoalListView(
                        store: store.scope(
                            state: \.goalList,
                            action: AppFeature.Action.goalList
                        )
                    )
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button(
                                action: {
                                    store.send(.view(.settingsButtonTapped))
                                },
                                label: {
                                    Image(systemName: "gearshape")
                                }
                            )
                        }
                    }
                    .sheet(
                        store: store.scope(
                            state: \.$destination.settings,
                            action: \.destination.settings
                        ),
                        content: SettingsView.init
                    )
                }
                .tabItem {
                    Label(L10n.App.Feature.goals, systemImage: "target")
                }
                .tag(AppFeature.State.Tab.goals)

                NavigationStack {
                    RunListView(
                        store: store.scope(
                            state: \.runList,
                            action: AppFeature.Action.runList
                        )
                    )
                }
                .tabItem {
                    Label(L10n.App.Feature.runs, systemImage: "figure.run")
                }
                .tag(AppFeature.State.Tab.runs)

                NavigationStack {
                    HistoryView(
                        store: store.scope(
                            state: \.history,
                            action: AppFeature.Action.history
                        )
                    )
                }
                .tabItem {
                    Label(L10n.App.Feature.history, systemImage: "clock.arrow.circlepath")
                }
                .tag(AppFeature.State.Tab.history)
            }
            .onAppear { store.send(.view(.onAppear)) }
            .tint(Color(asset: Asset.blue))
        }
    }
}

#Preview("Default") {
    AppView(
        store: .init(
            initialState: .init(
                permissions: nil,
                runList: .init(),
                goalList: .init()
            ),
            reducer: AppFeature.init,
            withDependencies: {
                $0.date = .constant(.preview)
            }
        )
    )
    .environment(\.locale, .init(identifier: "en_AU"))
}

#Preview("New Run") {
    let runningWorkouts: RunningWorkouts = .newRun(
        initialRuns: .initialRuns,
        newRun: .mock(
            distance: .init(
                value: 20,
                unit: .kilometers
            )
        )
    )

    return AppView(
        store: .init(
            initialState: .init(
                permissions: nil,
                runList: .init(),
                goalList: .init()
            ),
            reducer: { AppFeature() },
            withDependencies: {
                $0.date = .constant(.preview)
                $0.repository.runningWorkouts = runningWorkouts
            }
        )
    )
    .environment(\.locale, .init(identifier: "en_AU"))
}

extension [Run] {
    static var initialRuns: [Run] = [
        .mock(
            distance: .init(
                value: 20,
                unit: .kilometers
            )
        ),
    ]
}
