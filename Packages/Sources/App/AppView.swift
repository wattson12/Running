import ComposableArchitecture
import DesignSystem
import GoalList
import Model
import Permissions
import Program
import Repository
import Resources
import RunList
import Settings
import SwiftUI

@ViewAction(for: AppFeature.self)
public struct AppView: View {
    @Bindable public var store: StoreOf<AppFeature>
    @Environment(\.scenePhase) var scenePhase

    public init(store: StoreOf<AppFeature>) {
        self.store = store
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
                            action: \.goalList
                        )
                    )
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button(
                                action: {
                                    send(.settingsButtonTapped)
                                },
                                label: {
                                    Image(systemName: "gearshape")
                                }
                            )
                        }
                    }
                    .sheet(
                        item: $store.scope(
                            state: \.destination?.settings,
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
                            action: \.runList
                        )
                    )
                }
                .tabItem {
                    Label(L10n.App.Feature.runs, systemImage: "figure.run")
                }
                .tag(AppFeature.State.Tab.runs)

                if let store = store.scope(state: \.program, action: \.program) {
                    NavigationStack {
                        PlaceholderProgramView(store: store)
                    }
                    .tabItem {
                        Label(L10n.App.Feature.program, systemImage: "pencil.and.list.clipboard")
                    }
                    .tag(AppFeature.State.Tab.program)
                }
            }
            .onAppear { send(.onAppear) }
            .tint(Color(asset: Asset.blue))
            .onChange(of: scenePhase) { old, new in
                send(.scenePhaseUpdated(old, new))
            }
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
