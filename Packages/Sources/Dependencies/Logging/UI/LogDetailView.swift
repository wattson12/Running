import ComposableArchitecture
import SwiftUI

struct LogDetailView: View {
    let store: StoreOf<LogDetailFeature>

    var body: some View {
        WithViewStore(
            store,
            observe: { $0 }
        ) { viewStore in
            List {
                Section(
                    content: {
                        sectionContent(
                            rows: [
                                .init(
                                    label: "label",
                                    index: 0,
                                    element: viewStore.actionLabel
                                ),
                            ]
                        )
                    },
                    header: {
                        HStack {
                            Text("Action Label")
                        }
                    }
                )

                Section(
                    isExpanded: viewStore.binding(
                        get: \.actionExpanded,
                        send: { _ in
                            .view(.toggleActionExpandedTapped)
                        }
                    ),
                    content: {
                        sectionContent(rows: viewStore.actionLines)
                    },
                    header: {
                        HStack {
                            Text("Action")

                            Spacer()

                            Button("Toggle") {
                                viewStore.send(.view(.toggleActionExpandedTapped))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                )

                if let stateDiffLines = viewStore.diffLines {
                    Section(
                        isExpanded: viewStore.binding(
                            get: \.diffExpanded,
                            send: { _ in
                                .view(.toggleDiffExpandedTapped)
                            }
                        ),
                        content: {
                            sectionContent(rows: stateDiffLines)
                        },
                        header: {
                            HStack {
                                Text("State")

                                Spacer()

                                Button("Toggle") {
                                    viewStore.send(.view(.toggleDiffExpandedTapped))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    )
                }
            }
            .listStyle(.plain)
            .environment(\.defaultMinListRowHeight, 16)
            .navigationTitle(viewStore.actionLabel)
        }
    }

    @ViewBuilder private func sectionContent(rows: [LogDetailFeature.State.IndexedElement]) -> some View {
        ForEach(rows) { row in
            Text(row.element)
                .frame(height: 16)
                .listRowInsets(.init(top: 0, leading: 16, bottom: 0, trailing: 16))
        }
        .frame(height: 16)
        .listRowSeparator(.hidden)
    }
}

#Preview("No Diff") {
    NavigationStack {
        LogDetailView(
            store: .init(
                initialState: .init(log: .mock()),
                reducer: LogDetailFeature.init
            )
        )
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview("Diff") {
    NavigationStack {
        LogDetailView(
            store: .init(
                initialState: .init(
                    log: .mock(
                        stateDiff: """
                        + state: 12
                        - state: 0
                        """
                    )
                ),
                reducer: LogDetailFeature.init
            )
        )
        .navigationBarTitleDisplayMode(.inline)
    }
}
