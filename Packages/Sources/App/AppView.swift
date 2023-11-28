import ComposableArchitecture
import DesignSystem
import GoalList
import Permissions
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
            }
            .onAppear { store.send(.view(.onAppear)) }
            .tint(Color(asset: Asset.blue))
        }
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
