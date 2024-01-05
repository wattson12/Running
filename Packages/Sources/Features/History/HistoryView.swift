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
        List {
            Section(
                content: {
                    ForEach(store.totals) { total in
                        HStack {
                            Text(total.label)
                            Spacer()
                            Text(total.distance.fullValue(locale: locale))
                        }
                    }
                },
                footer: {
                    if let summary = store.summary {
                        VStack(alignment: .leading) {
                            Text("Distance: \(summary.distance.fullValue(locale: locale))")
                            Text("Duration: \(summary.duration.summaryValue(locale: locale))")
                            Text("Count: \(summary.count.description)")
                        }
                    }
                }
            )
        }
        .animation(.default, value: store.sortType)
        .onAppear { store.send(.view(.onAppear)) }
        .navigationTitle(L10n.History.title)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Section(L10n.History.Menu.Sort.title) {
                        Button(
                            action: {
                                store.send(.view(.sortByDateMenuButtonTapped))
                            },
                            label: {
                                HStack {
                                    if store.sortType == .date {
                                        Image(systemName: "checkmark")
                                    }
                                    Text(L10n.History.Menu.Sort.date)
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
                                    Text(L10n.History.Menu.Sort.distance)
                                }
                            }
                        )
                    }
                } label: {
                    Label(L10n.History.Menu.label, systemImage: "arrow.up.arrow.down")
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
