import ComposableArchitecture
import Dependencies
import DesignSystem
import GoalDetail
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
        Group {
            if store.totals.isEmpty {
                HistoryEmptyView()
            } else {
                List {
                    Section(
                        content: {
                            ForEach(store.totals) { total in
                                Button(
                                    action: {
                                        store.send(.view(.totalTapped(total)))
                                    },
                                    label: {
                                        HStack {
                                            Text(total.label)
                                            Spacer()
                                            Text(total.distance.fullValue(locale: locale))
                                        }
                                        .contentShape(Rectangle())
                                    }
                                )
                                .buttonStyle(.navigation)
                            }
                        },
                        footer: {
                            if let summary = store.summary {
                                VStack(alignment: .leading) {
                                    Text(L10n.History.Summary.distanceFormat(summary.distance.fullValue(locale: locale)))
                                    Text(L10n.History.Summary.durationFormat(summary.duration.summaryValue(locale: locale)))
                                    Text(L10n.History.Summary.countFormat(summary.count))
                                }
                            }
                        }
                    )
                }
                .animation(.default, value: store.sortType)
                .navigationDestination(
                    store: store.scope(
                        state: \.$destination.detail,
                        action: \.destination.detail
                    ),
                    destination: GoalDetailView.init
                )
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
        .onAppear { store.send(.view(.onAppear)) }
        .navigationTitle(L10n.History.title)
    }
}

#Preview("Populated") {
    NavigationStack {
        HistoryView(
            store: .init(
                initialState: HistoryFeature.State(
                    totals: [
                        .init(
                            id: .init(),
                            period: .yearly,
                            date: .now,
                            label: "2020",
                            sort: 2020,
                            distance: .init(
                                value: 100,
                                unit: .kilometers
                            )
                        ),
                    ]
                ),
                reducer: HistoryFeature.init,
                withDependencies: {
                    $0.locale = .init(identifier: "en-AU")
                }
            )
        )
    }
    .environment(\.locale, .init(identifier: "en-AU"))
}

#Preview("Empty") {
    NavigationStack {
        HistoryView(
            store: .init(
                initialState: HistoryFeature.State(
                    totals: []
                ),
                reducer: { HistoryFeature() },
                withDependencies: {
                    $0.repository.runningWorkouts._allRunningWorkouts = {
                        .mock(value: [])
                    }
                }
            )
        )
    }
    .environment(\.locale, .init(identifier: "en-AU"))
}
