import ComposableArchitecture
import Dependencies
import Model
import Repository
import SwiftUI

@Reducer
struct HistoryFeature: Reducer {
    @ObservableState
    struct State: Equatable {
        var totals: [IntervalTotal] = []
    }

    enum Action: Equatable {
        enum View: Equatable {
            case onAppear
        }

        case view(View)
    }

    @Dependency(\.repository.runningWorkouts) var runningWorkouts

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .view(action):
                return view(action, state: &state)
            }
        }
    }

    private func view(_ action: Action.View, state: inout State) -> EffectOf<Self> {
        switch action {
        case .onAppear:
            guard let allRuns = runningWorkouts.allRunningWorkouts.cache() else {
                return .none
            }

            state.totals = .init(runs: allRuns.sorted(by: { $0.startDate < $1.startDate }))

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
