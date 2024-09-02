import ComposableArchitecture
import Dependencies
import Model
import Repository
import Resources
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
                Menu {
                    Section(L10n.History.Menu.Sort.title) {
                        Button(
                            action: {
                                send(.setSortMode(.date))
                            },
                            label: {
                                HStack {
                                    if store.sortMode == .date {
                                        Image(systemName: "checkmark")
                                    }
                                    Text(L10n.History.Menu.Sort.date)
                                }
                            }
                        )
                        Button(
                            action: {
                                send(.setSortMode(.distance))
                            },
                            label: {
                                HStack {
                                    if store.sortMode == .distance {
                                        Image(systemName: "checkmark")
                                    }
                                    Text(L10n.History.Menu.Sort.distance)
                                }
                            }
                        )
                    }
                } label: {
                    Label(L10n.History.Menu.label, systemImage: "arrow.up.arrow.down")
                }
            }

            ToolbarItem(placement: .topBarTrailing) {
                Button(
                    action: { send(.closeButtonTapped) },
                    label: {
                        Image(systemName: "xmark")
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
