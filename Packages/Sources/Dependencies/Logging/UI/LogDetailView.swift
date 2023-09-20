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
                Section("Action") {
                    ForEach(viewStore.actionLines) { line in
                        Text(line.element)
                    }
                    .listRowSeparator(.hidden)
                    .listRowSpacing(0)
                }

                if let stateDiffLines = viewStore.diffLines {
                    Section("State") {
                        ForEach(stateDiffLines) { line in
                            Text(line.element)
                        }
                        .listRowSeparator(.hidden)
                    }
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
