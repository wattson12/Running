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

        init(state: AppFeature.State) {
            tab = state.tab
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
                                    state: \.$destination.settings,
                                    action: \.destination.settings
                                ),
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
