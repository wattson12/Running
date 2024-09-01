import ComposableArchitecture
import Resources
import SwiftUI

@ViewAction(for: SettingsFeature.self)
public struct SettingsView: View {
    @State public var store: StoreOf<SettingsFeature>

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

                if store.displayFeatureFlags {
                    Section(
                        header: Text(L10n.Settings.Section.betaFeatures),
                        content: {
                            Toggle(L10n.Settings.Section.BetaFeatures.runDetail, isOn: $store.runDetailEnabled)
                            Toggle(L10n.Settings.Section.BetaFeatures.program, isOn: $store.programEnabled)
                            Toggle("Goal history", isOn: $store.goalHistoryEnabled)
                        }
                    )
                }

                Section(
                    header: Text(L10n.Settings.Section.cache),
                    content: {
                        Button(L10n.Settings.Section.Cache.deleteAllRuns) { send(.deleteAllRunsTapped) }
                    }
                )
            }
            .buttonStyle(.plain)
            .navigationTitle(L10n.App.Feature.settings)
            .onAppear { send(.onAppear) }
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
            destination: URL(string: "https://wattson12.github.io/Running/terms/terms-and-conditions.html")!,
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
