import ComposableArchitecture
import Dependencies
import Model
import Repository
import SwiftUI

struct GoalHistory: Equatable, Identifiable {
    let id: Int
    let dateRange: DateRange
    let runs: [Run]
    let target: Measurement<UnitLength>?
}

@Reducer
public struct GoalHistoryFeature {
    @ObservableState
    public struct State: Equatable {
        let period: Goal.Period
        var history: [GoalHistory] = []

        public init(period: Goal.Period) {
            self.period = period
        }
    }

    @CasePathable
    public enum Action: ViewAction, Equatable {
        @CasePathable
        public enum View: Equatable {
            case onAppear
        }

        case view(View)
    }

    @Dependency(\.repository.runningWorkouts) var runningWorkouts
    @Dependency(\.repository.goals) var goals
    @Dependency(\.calendar) var calendar
    @Dependency(\.date) var date

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
            guard let cachedRuns = runningWorkouts.allRunningWorkouts.cache() else { return .none }
            let sortedRuns = cachedRuns.sorted(by: { $0.startDate < $1.startDate })
            guard let firstRun = sortedRuns.first else { return .none }
            print("cached runs", cachedRuns.count)
            print("first run", cachedRuns.first)
            print("last run", cachedRuns.last)

            let target = try! goals.goal(in: state.period).target

            var ranges: [DateRange] = []
            var history: [GoalHistory] = []
            guard var range = state.period.startAndEnd(in: calendar, now: date.now) else { return .none }
            ranges.append(.init(period: state.period, start: range.start, end: range.end))

            let matchingRuns = try! runningWorkouts.runs(within: .init(period: state.period, target: nil), date: range.start)
            history.append(.init(id: history.count, dateRange: .init(period: state.period, start: range.start, end: range.end), runs: matchingRuns, target: target))

            while range.end > firstRun.startDate {
                let offsetComponent: Calendar.Component
                switch state.period {
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

                let newRange: DateRange = .init(period: state.period, start: newStart, end: newEnd)
                ranges.append(newRange)
                range = (newRange.start, newRange.end)

                let matchingRuns = try! runningWorkouts.runs(within: .init(period: state.period, target: nil), date: newRange.start)
                history.append(.init(id: history.count, dateRange: newRange, runs: matchingRuns, target: target))
            }

            state.history = history

            return .none
        }
    }
}

@ViewAction(for: GoalHistoryFeature.self)
public struct GoalHistoryView: View {
    public let store: StoreOf<GoalHistoryFeature>

    @Environment(\.locale) var locale

    public init(store: StoreOf<GoalHistoryFeature>) {
        self.store = store
    }

    public var body: some View {
        List {
            ForEach(store.history
            ) { history in
                GoalHistoryRow(history: history)
            }
        }
        .navigationTitle(store.period.displayName)
        .onAppear { send(.onAppear) }
    }
}

#Preview {
    NavigationStack {
        GoalHistoryView(
            store: .init(
                initialState: .init(period: .yearly),
                reducer: GoalHistoryFeature.init
            )
        )
    }
}
