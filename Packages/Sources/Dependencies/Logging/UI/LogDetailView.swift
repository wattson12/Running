import ComposableArchitecture
import SwiftUI

struct LogDetailView: View {
    let store: StoreOf<LogDetailFeature>

    var body: some View {
        WithViewStore(
            store,
            observe: { $0 }
        ) { viewStore in
            VStack(alignment: .leading) {
                Text(viewStore.action)
                if let stateDiff = viewStore.stateDiff {
                    ForEach(stateDiff, id: \.self) { diff in
                        Text(diff)
                    }
                }
                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
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
                    stateDiff: [
                        "+ state: 12",
                        "- state: 0",
                    ]
                ),
                reducer: LogDetailFeature.init
            )
        )
        .navigationBarTitleDisplayMode(.inline)
    }
}
