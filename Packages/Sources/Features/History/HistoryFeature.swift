import ComposableArchitecture
import Dependencies
import Model
import Repository

@Reducer
public struct HistoryFeature: Reducer {
    @ObservableState
    public struct State: Equatable {
        public enum SortType: Equatable {
            case date
            case distance
        }

        var totals: [IntervalTotal]
        var sortType: SortType

        public init(
            totals: [IntervalTotal] = [],
            sortType: SortType = .date
        ) {
            self.totals = totals
            self.sortType = sortType
        }

        mutating func sortTotals() {
            switch sortType {
            case .date:
                totals.sort(by: { $0.sort < $1.sort })
            case .distance:
                totals.sort(by: { $0.distance > $1.distance })
            }
        }
    }

    public enum Action: Equatable {
        public enum View: Equatable {
            case onAppear
            case sortByDateMenuButtonTapped
            case sortByDistanceMenuButtonTapped
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
                state.totals = []
                return .none
            }

            state.totals = .init(runs: allRuns.sorted(by: { $0.startDate < $1.startDate }))
            state.sortTotals()

            return .none
        case .sortByDateMenuButtonTapped:
            state.sortType = .date
            state.sortTotals()
            return .none
        case .sortByDistanceMenuButtonTapped:
            state.sortType = .distance
            state.sortTotals()
            return .none
        }
    }
}
