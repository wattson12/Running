import ComposableArchitecture
import Dependencies
import Model
import Repository

@Reducer
public struct HistoryFeature: Reducer {
    @ObservableState
    public struct State: Equatable {
        var totals: [IntervalTotal] = []

        public init(totals: [IntervalTotal] = []) {
            self.totals = totals
        }
    }

    public enum Action: Equatable {
        public enum View: Equatable {
            case onAppear
        }

        case view(View)
    }

    @Dependency(\.repository.runningWorkouts) var runningWorkouts

    public init() {}

    public var body: some ReducerOf<Self> {
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
