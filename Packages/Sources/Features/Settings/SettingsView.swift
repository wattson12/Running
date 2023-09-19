import ComposableArchitecture
import Logging
import Resources
import SwiftUI

public struct SettingsView: View {
    struct ViewState: Equatable {
        let versionNumber: String
        let buildNumber: String
        let acknowledgements: [Acknowledgement]
        let debugSectionVisible: Bool
        let debugTabVisible: Bool

        init(state: SettingsFeature.State) {
            versionNumber = state.versionNumber
            buildNumber = state.buildNumber
            acknowledgements = state.acknowledgements.elements
            debugSectionVisible = state.debugSectionVisible
            debugTabVisible = state.debugTabVisible
        }
    }

    let store: StoreOf<SettingsFeature>

    public init(store: StoreOf<SettingsFeature>) {
        self.store = store
    }

    public var body: some View {
        NavigationStack {
            WithViewStore(store, observe: ViewState.init, send: SettingsFeature.Action.view) { viewStore in
                List {
                    Section(L10n.Settings.Section.acknowledgements) {
                        ForEach(viewStore.acknowledgements) { acknowledgement in
                            Link(
                                acknowledgement.name,
                                destination: acknowledgement.url
                            )
                        }
                    }

                    if viewStore.debugSectionVisible {
                        Section(L10n.Settings.Section.BuildInfo.title) {
                            buildInfoSection(
                                state: viewStore.state
                            )
                        }
                    } else {
                        Section(
                            header: Text(L10n.Settings.Section.BuildInfo.title),
                            footer: debugSectionGestureView {
                                viewStore.send(.hiddenAreaGestureFired)
                            },
                            content: {
                                buildInfoSection(
                                    state: viewStore.state
                                )
                            }
                        )
                    }

                    if viewStore.debugSectionVisible {
                        Section(
                            header: Text(L10n.Settings.Section.Debug.title),
                            footer: debugSectionGestureView {
                                viewStore.send(.hiddenAreaGestureFired)
                            },
                            content: {
                                HStack {
                                    Text(L10n.Settings.Section.Debug.showDebugTab)
                                    Spacer()
                                    Toggle(
                                        "",
                                        isOn: viewStore.binding(
                                            get: \.debugTabVisible,
                                            send: { .setDebugTabVisible($0) }
                                        )
                                    )
                                }

                                Button(
                                    action: {
                                        viewStore.send(.showLoggingButtonTapped)
                                    },
                                    label: {
                                        Text("Show Logging")
                                    }
                                )
                            }
                        )
                    }
                }
                .sheet(
                    store: store.scope(
                        state: \.$destination,
                        action: SettingsFeature.Action.destination
                    ),
                    state: /SettingsFeature.Destination.State.logging,
                    action: SettingsFeature.Destination.Action.logging,
                    content: LogListView.init
                )
                .navigationTitle(L10n.App.Feature.settings)
                .onAppear { viewStore.send(.onAppear) }
            }
        }
    }

    @ViewBuilder func buildInfoSection(state: ViewState) -> some View {
        HStack {
            Text(L10n.Settings.Section.BuildInfo.version)
            Spacer()
            Text(state.versionNumber)
                .font(.footnote)
        }

        HStack {
            Text(L10n.Settings.Section.BuildInfo.buildNumber)
            Spacer()
            Text(state.buildNumber)
                .font(.footnote)
        }
    }

    @ViewBuilder func debugSectionGestureView(action: @escaping () -> Void) -> some View {
        Color.clear
            .contentShape(Rectangle())
            .frame(height: 100)
            .onTapGesture(count: 5) {
                action()
            }
    }
}

#Preview {
    SettingsView(
        store: .init(
            initialState: .init(),
            reducer: { SettingsFeature()._logging() }
        )
    )
}
