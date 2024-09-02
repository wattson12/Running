import ComposableArchitecture
import Dependencies
import Foundation
import Model
import Repository

@Reducer
public struct GoalHistoryFeature {
    @ObservableState
    public struct State: Equatable {
        public enum SortMode: Equatable {
            case date
            case distance
        }

        let period: Goal.Period
        var history: [GoalHistory] = []
        var sortMode: SortMode = .date

        public init(period: Goal.Period) {
            self.period = period
        }

        mutating func refreshHistory() {
            @Dependency(\.repository.runningWorkouts) var runningWorkouts
            @Dependency(\.repository.goals) var goals
            @Dependency(\.calendar) var calendar
            @Dependency(\.date) var date

            guard let cachedRuns = runningWorkouts.allRunningWorkouts.cache() else { return }
            let sortedRuns = cachedRuns.sorted(by: { $0.startDate < $1.startDate })
            guard let firstRun = sortedRuns.first else { return }

            guard let target = try? goals.goal(in: period).target else { return }

            var ranges: [DateRange] = []
            var history: [GoalHistory] = []
            guard var range = period.startAndEnd(in: calendar, now: date.now) else { return }
            ranges.append(.init(period: period, start: range.start, end: range.end))

            guard let matchingRuns = try? runningWorkouts.runs(within: .init(period: period, target: nil), date: range.start) else { return }
            history.append(.init(id: history.count, dateRange: .init(period: period, start: range.start, end: range.end), runs: matchingRuns, target: target))

            while range.end > firstRun.startDate {
                let offsetComponent: Calendar.Component
                switch period {
                case .weekly:
                    offsetComponent = .weekOfYear
                case .monthly:
                    offsetComponent = .month
                case .yearly:
                    offsetComponent = .year
                }

                guard let newStart = calendar.date(byAdding: offsetComponent, value: -1, to: range.start) else {
                    break
                }
                guard newStart <= date.now else { break }
                guard let newEnd = calendar.date(byAdding: offsetComponent, value: -1, to: range.end) else { break }

                let newRange: DateRange = .init(period: period, start: newStart, end: newEnd)
                ranges.append(newRange)
                range = (newRange.start, newRange.end)

                guard let matchingRuns = try? runningWorkouts.runs(within: .init(period: period, target: nil), date: newRange.start) else { break }
                history.append(.init(id: history.count, dateRange: newRange, runs: matchingRuns, target: target))
            }

            self.history = history
        }
    }

    @CasePathable
    public enum Action: ViewAction, Equatable {
        @CasePathable
        public enum View: Equatable {
            case onAppear
            case closeButtonTapped
            case setSortMode(State.SortMode)
        }

        case view(View)
    }

    @Dependency(\.dismiss) var dismiss

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
            state.refreshHistory()
            return .none
        case .closeButtonTapped:
            return .run { _ in await dismiss() }
        case let .setSortMode(mode):
            state.sortMode = mode
            switch mode {
            case .date:
                state.history = state.history.sorted(by: { $0.dateRange.start > $1.dateRange.start })
            case .distance:
                state.history = state.history.sorted(by: { $0.distance > $1.distance })
            }
            return .none
        }
    }
}
