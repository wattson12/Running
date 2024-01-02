import ComposableArchitecture
import Dependencies
import Repository
import SwiftUI

@Reducer
struct HistoryFeature: Reducer {
    @ObservableState
    struct State: Equatable {
        struct IntervalTotal: Identifiable, Equatable {
            let id: UUID
            let label: String
            let distance: Measurement<UnitLength>
        }

        var totals: [IntervalTotal] = []
    }

    enum Action: Equatable {
        enum View: Equatable {
            case onAppear
        }

        case view(View)
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .view(action):
                return view(action, state: &state)
            }
        }
    }

    private func view(_ action: Action.View, state _: inout State) -> EffectOf<Self> {
        switch action {
        case .onAppear:
            return .none
        }
    }
}

struct HistoryView: View {
    let store: StoreOf<HistoryFeature>

    @Environment(\.locale) var locale

    var body: some View {
        List(store.totals) { total in
            HStack {
                Text(total.label)
                Spacer()
                Text(total.distance.fullValue(locale: locale))
            }
        }
    }
}

#Preview {
    HistoryView(
        store: .init(
            initialState: .init(
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
            reducer: HistoryFeature.init
        )
    )
    .environment(\.locale, .init(identifier: "en-AU"))
}
