import ComposableArchitecture
import Logging
import Resources
import SwiftUI

public struct SettingsView: View {
    @State var store: StoreOf<SettingsFeature>

    public init(store: StoreOf<SettingsFeature>) {
        self.store = store
    }

    public var body: some View {
        NavigationStack {
            List {
                Section(L10n.Settings.Section.Links.title) {
                    linksSection()
                }

                Section(L10n.Settings.Section.acknowledgements) {
                    ForEach(store.acknowledgements) { acknowledgement in
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

                Section(L10n.Settings.Section.BuildInfo.title) {
                    buildInfoSection()
                }

                Section(
                    header: Text("Beta Features"),
                    content: {
                        Toggle("Run detail", isOn: $store.showRunDetailFeatureFlag)
                    }
                )

                Section(
                    header: Text("Cache"),
                    content: {
                        Button("Delete all runs") { store.send(.view(.deleteAllRunsTapped)) }
                    }
                )

                Section(
                    header: Text(L10n.Settings.Section.Debug.title),
                    content: {
                        Button(
                            action: {
                                store.send(.view(.showLoggingButtonTapped))
                            },
                            label: {
                                Text(L10n.Settings.Section.Debug.showLogging)
                            }
                        )
                    }
                )
            }
            .sheet(
                isPresented: .constant(false),
                //                    isPresented: $store.loggingDisplayed.sending(\.loggingDisplayed),
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
            .onAppear { store.send(.view(.onAppear)) }
        }
    }

    @ViewBuilder func buildInfoSection() -> some View {
        HStack {
            Text(L10n.Settings.Section.BuildInfo.version)
            Spacer()
            Text(store.versionNumber)
                .font(.footnote)
        }

        HStack {
            Text(L10n.Settings.Section.BuildInfo.buildNumber)
            Spacer()
            Text(store.buildNumber)
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
}

#Preview {
    SettingsView(
        store: .init(
            initialState: .init(),
            reducer: SettingsFeature.init
        )
    )
}
