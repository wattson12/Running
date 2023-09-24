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
        let loggingDisplayed: Bool

        init(state: SettingsFeature.State) {
            versionNumber = state.versionNumber
            buildNumber = state.buildNumber
            acknowledgements = state.acknowledgements.elements
            debugSectionVisible = state.debugSectionVisible
            loggingDisplayed = state.loggingDisplayed
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

                    Section("About") {
                        aboutSection()
                    }

                    if viewStore.debugSectionVisible {
                        Section(
                            header: Text(L10n.Settings.Section.Debug.title),
                            footer: debugSectionGestureView {
                                viewStore.send(.hiddenAreaGestureFired)
                            },
                            content: {
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
                    isPresented: viewStore.binding(
                        get: \.loggingDisplayed,
                        send: { .loggingDisplayed($0) }
                    ),
                    content: {
                        LogListView(
                            store: .init(
                                initialState: .init(),
                                reducer: LogListFeature.init,
                                withDependencies: {
                                    #if targetEnvironment(simulator)
                                        $0 = .preview
                                    #endif
                                }
                            )
                        )
                    }
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

    @ViewBuilder func aboutSection() -> some View {
        Link(
            "Terms & Conditions",
            destination: URL(string: "https://wattson12.github.io/Running/terms/terms.html")!
        )

        Link(
            "Privacy",
            destination: URL(string: "https://wattson12.github.io/Running/privacy/privacy.html")!
        )
        .buttonStyle(.plain)
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
