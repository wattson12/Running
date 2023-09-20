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
                    isExpanded: viewStore.binding(
                        get: \.actionExpanded,
                        send: { _ in
                            .view(.toggleActionExpandedTapped)
                        }
                    ),
                    content: {
                        ForEach(viewStore.actionLines) { line in
                            Text(line.element)
                        }
                        .listRowSeparator(.hidden)
                        .listRowSpacing(0)
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
                            ForEach(stateDiffLines) { line in
                                Text(line.element)
                            }
                            .listRowSeparator(.hidden)
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
            .listRowSpacing(-16)
            .navigationTitle(viewStore.actionLabel)
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
