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
        }
    }
}

@ViewAction(for: GoalHistoryFeature.self)
public struct GoalHistoryView: View {
    public let store: StoreOf<GoalHistoryFeature>

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
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(
                    action: { send(.closeButtonTapped) },
                    label: {
                        Image(systemName: "xmark.circle")
                    }
                )
            }
        }
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
