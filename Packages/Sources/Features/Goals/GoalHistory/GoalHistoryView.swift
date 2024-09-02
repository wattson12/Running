import ComposableArchitecture
import Dependencies
import Model
import Repository
import SwiftUI

@ViewAction(for: GoalHistoryFeature.self)
public struct GoalHistoryView: View {
    public let store: StoreOf<GoalHistoryFeature>

    public init(store: StoreOf<GoalHistoryFeature>) {
        self.store = store
    }

    public var body: some View {
        List {
            ForEach(store.history
            ) { history in
                GoalHistoryRow(history: history)
            }
        }
        .navigationTitle(store.period.displayName)
        .onAppear { send(.onAppear) }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(
                    action: { send(.closeButtonTapped) },
                    label: {
                        Image(systemName: "xmark.circle")
                    }
                )
            }
        }
    }
}

#Preview {
    NavigationStack {
        GoalHistoryView(
            store: .init(
                initialState: .init(period: .yearly),
                reducer: GoalHistoryFeature.init
            )
        )
    }
}
