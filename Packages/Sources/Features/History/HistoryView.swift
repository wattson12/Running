import ComposableArchitecture
import Dependencies
import Model
import Repository
import Resources
import SwiftUI

public struct HistoryView: View {
    let store: StoreOf<HistoryFeature>

    @Environment(\.locale) var locale

    public init(store: StoreOf<HistoryFeature>) {
        self.store = store
    }

    public var body: some View {
        List(store.totals) { total in
            HStack {
                Text(total.label)
                Spacer()
                Text(total.distance.fullValue(locale: locale))
            }
        }
        .onAppear { store.send(.view(.onAppear)) }
        .navigationTitle(L10n.History.title)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Section("Sort") {
                        Button(
                            action: {
                                store.send(.view(.sortByDateMenuButtonTapped))
                            },
                            label: {
                                HStack {
                                    if store.sortType == .date {
                                        Image(systemName: "checkmark")
                                    }
                                    Text("Date")
                                }
                            }
                        )
                        Button(
                            action: {
                                store.send(.view(.sortByDistanceMenuButtonTapped))
                            },
                            label: {
                                HStack {
                                    if store.sortType == .distance {
                                        Image(systemName: "checkmark")
                                    }
                                    Text("Distance")
                                }
                            }
                        )
                    }
                } label: {
                    Label("Sort", systemImage: "arrow.up.arrow.down")
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        HistoryView(
            store: .init(
                initialState: HistoryFeature.State(
                    totals: [
                        .init(
                            id: .init(),
                            label: "2020",
                            sort: 2020,
                            distance: .init(
                                value: 100,
                                unit: .kilometers
                            )
                        ),
                    ]
                ),
                reducer: { HistoryFeature() }
            )
        )
        .environment(\.locale, .init(identifier: "en-AU"))
    }
}
