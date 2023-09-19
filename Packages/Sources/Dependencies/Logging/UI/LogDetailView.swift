import ComposableArchitecture
import SwiftUI

struct LogDetailView: View {
    let store: StoreOf<LogDetailFeature>

    var body: some View {
        WithViewStore(
            store,
            observe: { $0 }
        ) { viewStore in
            ScrollView {
                LazyVStack(alignment: .leading) {
                    Text(viewStore.actionLabel)

                    ForEach(Array(viewStore.action.components(separatedBy: .newlines).enumerated()), id: \.offset) { _, line in
                        Text(line)
                    }

                    if let stateDiff = viewStore.stateDiff {
                        ForEach(Array(stateDiff.components(separatedBy: .newlines).enumerated()), id: \.offset) { _, line in
                            Text(line)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle(viewStore.actionLabel)
        }
    }
}

#Preview("No Diff") {
    NavigationStack {
        LogDetailView(
            store: .init(
                initialState: .mock(),
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
                initialState: .mock(
                    stateDiff: """
                    + state: 12
                    - state: 0
                    """
                ),
                reducer: LogDetailFeature.init
            )
        )
        .navigationBarTitleDisplayMode(.inline)
    }
}
