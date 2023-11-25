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
        @BindingViewState var showRunDetail: Bool

        init(state: BindingViewStore<SettingsFeature.State>) {
            versionNumber = state.versionNumber
            buildNumber = state.buildNumber
            acknowledgements = state.acknowledgements.elements
            debugSectionVisible = state.debugSectionVisible
            loggingDisplayed = state.loggingDisplayed
            _showRunDetail = state.$showRunDetailFeatureFlag
        }
    }

    let store: StoreOf<SettingsFeature>

    public init(store: StoreOf<SettingsFeature>) {
        self.store = store
    }

    public var body: some View {
        NavigationStack {
            WithViewStore(
                store,
                observe: ViewState.init
            ) { viewStore in
                List {
                    Section(L10n.Settings.Section.Links.title) {
                        linksSection()
                    }

                    Section(L10n.Settings.Section.acknowledgements) {
                        ForEach(viewStore.acknowledgements) { acknowledgement in
                            Link(
                                destination: acknowledgement.url,
                                label: {
                                    HStack {
                                        Text(acknowledgement.name)
                                        Spacer()
                                        Image(systemName: "network")
                                    }
                                }
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
                                viewStore.send(.view(.hiddenAreaGestureFired))
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
                            header: Text("Feature Flags"),
                            content: {
                                Toggle("Show run detail", isOn: viewStore.$showRunDetail)
                            }
                        )

                        Section(
                            header: Text("Cache"),
                            content: {
                                Button("Delete all runs") { viewStore.send(.view(.deleteAllRunsTapped)) }
                            }
                        )

                        Section(
                            header: Text(L10n.Settings.Section.Debug.title),
                            footer: debugSectionGestureView {
                                viewStore.send(.view(.hiddenAreaGestureFired))
                            },
                            content: {
                                Button(
                                    action: {
                                        viewStore.send(.view(.showLoggingButtonTapped))
                                    },
                                    label: {
                                        Text(L10n.Settings.Section.Debug.showLogging)
                                    }
                                )
                            }
                        )
                    }
                }
                .sheet(
                    isPresented: viewStore.binding(
                        get: \.loggingDisplayed,
                        send: { .view(.loggingDisplayed($0)) }
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
                .buttonStyle(.plain)
                .navigationTitle(L10n.App.Feature.settings)
                .onAppear { viewStore.send(.view(.onAppear)) }
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

    @ViewBuilder func linksSection() -> some View {
        Link(
            destination: URL(string: "https://github.com/wattson12/Running")!,
            label: {
                HStack {
                    Text(L10n.Settings.Section.Links.sourceCode)
                    Spacer()
                    Image(systemName: "network")
                }
            }
        )

        Link(
            destination: URL(string: "https://wattson12.github.io/Running/terms/terms.html")!,
            label: {
                HStack {
                    Text(L10n.Settings.Section.Links.terms)
                    Spacer()
                    Image(systemName: "network")
                }
            }
        )

        Link(
            destination: URL(string: "https://wattson12.github.io/Running/privacy/privacy.html")!,
            label: {
                HStack {
                    Text(L10n.Settings.Section.Links.privacy)
                    Spacer()
                    Image(systemName: "network")
                }
            }
        )
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
            reducer: SettingsFeature.init
        )
    )
}
