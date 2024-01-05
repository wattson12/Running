import ComposableArchitecture
import Dependencies
import Foundation
import Model
import Repository

public struct HistorySummary: Equatable {
    let distance: Measurement<UnitLength>
    let duration: Measurement<UnitDuration>
    let count: Int

    public init(
        distance: Measurement<UnitLength>,
        duration: Measurement<UnitDuration>,
        count: Int
    ) {
        self.distance = distance
        self.duration = duration
        self.count = count
    }
}

extension HistorySummary {
    init(runs: [Run]) {
        var distance: Measurement<UnitLength> = .init(value: 0, unit: .kilometers)
        var duration: Measurement<UnitDuration> = .init(value: 0, unit: .seconds)

        for run in runs {
            distance = distance + run.distance
            duration = duration + run.duration
        }

        self = .init(
            distance: distance,
            duration: duration,
            count: runs.count
        )
    }
}

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
        var summary: HistorySummary?

        public init(
            totals: [IntervalTotal] = [],
            sortType: SortType = .date,
            summary: HistorySummary? = nil
        ) {
            self.totals = totals
            self.sortType = sortType
            self.summary = summary
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

            state.summary = .init(runs: allRuns)

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
