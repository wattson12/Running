import ComposableArchitecture
import Dependencies
import Model
import Repository
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
    }
}

#Preview {
    HistoryView(
        store: .init(
            initialState: HistoryFeature.State(
                totals: [
                    .init(
                        id: .init(),
                        label: "2020",
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
