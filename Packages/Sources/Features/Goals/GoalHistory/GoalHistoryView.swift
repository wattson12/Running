import ComposableArchitecture
import Dependencies
import Model
import Repository
import SwiftUI

@Reducer
public struct GoalHistoryFeature {
    public struct State: Equatable {
        let period: Goal.Period

        public init(period: Goal.Period) {
            self.period = period
        }
    }

    public enum Action: ViewAction, Equatable {
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
            guard let cachedRuns = runningWorkouts.allRunningWorkouts.cache(), let firstRun = cachedRuns.first else { return .none }

            var ranges: [DateRange] = []
            guard var range = state.period.startAndEnd(in: calendar, now: date.now) else { return .none }
            ranges.append(.init(period: state.period, start: range.start, end: range.end))

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
            }

            let final = ranges.reversed()
            print(final)

            return .none
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
        Text("Goal History")
            .onAppear { send(.onAppear) }
    }
}

#Preview {
    GoalHistoryView(
        store: .init(
            initialState: .init(period: .yearly),
            reducer: GoalHistoryFeature.init
        )
    )
}
