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
                        Text(viewStore.actionLabel)
                            .font(.caption)
                            .listRowInsets(.init(top: 0, leading: 16, bottom: 0, trailing: 16))
                            .listRowSeparator(.hidden)
                    },
                    header: {
                        HStack {
                            Text("Action Name")
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
            .navigationTitle("Action")
        }
    }

    @ViewBuilder private func sectionContent(rows: [LogDetailFeature.State.IndexedElement]) -> some View {
        ForEach(rows) { row in
            Text(row.element)
                .font(.caption)
                .foregroundStyle(foregroundColor(for: row))
                .listRowInsets(.init(top: 0, leading: 16, bottom: 0, trailing: 16))
                .lineLimit(nil)
        }
        .frame(height: 16)
        .listRowSeparator(.hidden)
    }

    func foregroundColor(for row: LogDetailFeature.State.IndexedElement) -> Color {
        if row.element.hasPrefix("+") {
            return .red
        } else if row.element.hasPrefix("-") {
            return .green
        } else {
            return .primary
        }
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
