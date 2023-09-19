import ComposableArchitecture
import DesignSystem
import GoalList
import Permissions
import Resources
import RunList
import Settings
import SwiftUI

public struct AppView: View {
    struct ViewState: Equatable {
        let tab: AppFeature.State.Tab
        let debugTabVisible: Bool

        init(state: AppFeature.State) {
            tab = state.tab
            debugTabVisible = state.debugTabVisible
        }
    }

    let store: StoreOf<AppFeature>

    public init(store: StoreOf<AppFeature>) {
        self.store = store
    }

    public var body: some View {
        IfLetStore(
            store.scope(
                state: \.permissions,
                action: AppFeature.Action.permissions
            ),
            then: PermissionsView.init,
            else: {
                WithViewStore(
                    store,
                    observe: ViewState.init,
                    send: AppFeature.Action.view
                ) { viewStore in
                    TabView(
                        selection: viewStore.binding(
                            get: \.tab,
                            send: AppFeature.Action.View.updateTab
                        )
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
                                            viewStore.send(.settingsButtonTapped)
                                        },
                                        label: {
                                            Image(systemName: "gearshape")
                                        }
                                    )
                                }
                            }
                            .sheet(
                                store: store.scope(
                                    state: \.$destination,
                                    action: AppFeature.Action.destination
                                ),
                                state: /AppFeature.Destination.State.settings,
                                action: AppFeature.Destination.Action.settings,
                                content: SettingsView.init
                            )
                        }
                        .tabItem {
                            Label(L10n.App.Feature.goals, systemImage: "target")
                        }

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

                        if viewStore.debugTabVisible {
                            NavigationStack {
                                DebugView(
                                    store: store.scope(
                                        state: \.debug,
                                        action: AppFeature.Action.debug
                                    )
                                )
                            }
                            .tabItem {
                                Label(L10n.App.Feature.debug, systemImage: "stethoscope.circle")
                            }
                        }
                    }
                    .onAppear { viewStore.send(.onAppear) }
                    .tint(Color(asset: Asset.blue))
                }
            }
        )
    }
}

struct AppView_Previews: PreviewProvider {
    static var previews: some View {
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
}
