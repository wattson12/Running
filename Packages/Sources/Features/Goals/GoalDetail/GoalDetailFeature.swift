import ComposableArchitecture
import FeatureFlags
import Foundation
import GoalHistory
import Model

@Reducer
public struct GoalDetailFeature: Reducer {
    @Reducer(state: .equatable, action: .equatable)
    public enum Destination {
        case history(GoalHistoryFeature)
    }

    @ObservableState
    public struct State: Equatable {
        let goal: Goal
        let intervalDate: Date?
        var runs: [Run]?
        var emptyStateRuns: [Run]

        @Shared var showTarget: Bool
        @Shared var showRate: Bool

        @Shared(.featureFlag(.goalHistory)) var goalHistoryEnabled: Bool = false

        @Presents var destination: Destination.State?

        public init(
            goal: Goal,
            intervalDate: Date? = nil,
            runs: [Run]? = nil,
            emptyStateRuns: [Run] = [],
            showTarget: Bool = false,
            showRate: Bool = false,
            destination: Destination.State? = nil
        ) {
            self.goal = goal
            self.intervalDate = intervalDate
            self.runs = runs
            self.emptyStateRuns = emptyStateRuns

            _showTarget = .init(wrappedValue: showTarget, .appStorage("show_target_\(goal.period.rawValue)"))
            _showRate = .init(wrappedValue: showRate, .appStorage("show_rate_\(goal.period.rawValue)"))

            self.destination = destination
        }

        var title: String {
            if let intervalDate {
                let dateFormatter: DateFormatter = .rangeTitle(for: goal.period)
                return dateFormatter.string(from: intervalDate)
            } else {
                return goal.period.rawValue.capitalized
            }
        }

        var totalDuration: Measurement<UnitDuration>? {
            guard let runs, !runs.isEmpty else { return nil }
            return runs
                .map(\.duration)
                .reduce(.init(value: 0, unit: .minutes)) { $0 + $1 }
        }

        var averageDuration: Measurement<UnitDuration>? {
            guard let runs, !runs.isEmpty, let totalDuration else { return nil }
            return totalDuration / Double(runs.count)
        }

        var averageDistance: Measurement<UnitLength>? {
            guard let runs, !runs.isEmpty else { return nil }
            let total = runs.distance
            return total / Double(runs.count)
        }

        mutating func updateEmptyStateRuns(
            calendar: Calendar,
            date: DateGenerator,
            uuid: UUIDGenerator
        ) {
            guard runs?.isEmpty != false else { return }
            // skip recalculation if we populated empty state initially
            guard emptyStateRuns.isEmpty else { return }

            guard let range = goal.period.startAndEnd(in: calendar, now: intervalDate ?? date.now) else { return }
            let numberOfDaysInRangeComponents = calendar.dateComponents([.day], from: range.start, to: range.end)
            guard let numberOfDaysInRange = numberOfDaysInRangeComponents.day else { return }

            guard let goal = goal.target else { return }

            let emptyStateDistance: Measurement<UnitLength> = .init(value: goal.value * 1.2, unit: goal.unit)
            let numberOfRuns = Int(numberOfDaysInRange / 2)

            let timeBetweenRuns = numberOfDaysInRange / numberOfRuns

            var currentDate = range.start
            var runs: [Run] = []

            let distance: Measurement<UnitLength> = .init(value: emptyStateDistance.value / Double(numberOfRuns), unit: goal.unit)
            let duration: Measurement<UnitDuration> = .init(value: distance.converted(to: .kilometers).value * 5, unit: .minutes)

            for _ in 0 ..< numberOfRuns {
                runs.append(
                    .init(
                        id: uuid(),
                        startDate: currentDate,
                        distance: distance,
                        duration: duration,
                        detail: nil
                    )
                )

                currentDate = calendar.date(byAdding: .day, value: timeBetweenRuns, to: currentDate) ?? currentDate
            }
            emptyStateRuns = runs
        }
    }

    @CasePathable
    public enum Action: Equatable, ViewAction, BindableAction {
        @CasePathable
        public enum View: Equatable {
            case onAppear
            case historyButtonTapped
        }

        @CasePathable
        public enum Internal: Equatable {
            case runsFetched(TaskResult<[Run]>)
        }

        case view(View)
        case _internal(Internal)
        case binding(_ action: BindingAction<State>)
        case destination(PresentationAction<Destination.Action>)
    }

    @Dependency(\.calendar) var calendar
    @Dependency(\.date) var date
    @Dependency(\.repository.runningWorkouts) var runningWorkouts
    @Dependency(\.repository.goals) var goals
    @Dependency(\.uuid) var uuid

    public init() {}

    public var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case let .view(action):
                return view(action, state: &state)
            case let ._internal(action):
                return _internal(action, state: &state)
            case .binding:
                return .none
            case .destination:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }

    private func view(_ action: Action.View, state: inout State) -> Effect<Action> {
        switch action {
        case .onAppear:
            if let runsForGoal = try? runningWorkouts.runs(within: state.goal, date: state.intervalDate) {
                state.runs = runsForGoal
                state.updateEmptyStateRuns(calendar: calendar, date: date, uuid: uuid)
            }

            return .run { [goal = state.goal, intervalDate = state.intervalDate] send in
                let result = await TaskResult {
                    _ = try await runningWorkouts.allRunningWorkouts.remote()
                    return try runningWorkouts.runs(within: goal, date: intervalDate)
                }
                await send(._internal(.runsFetched(result)))
            }
        case .historyButtonTapped:
            guard state.goalHistoryEnabled else { return .none }
            state.destination = .history(.init(period: state.goal.period))
            return .none
        }
    }

    private func _internal(_ action: Action.Internal, state: inout State) -> Effect<Action> {
        switch action {
        case let .runsFetched(.success(runs)):
            state.runs = runs
            state.updateEmptyStateRuns(calendar: calendar, date: date, uuid: uuid)
            return .none
        case .runsFetched(.failure):
            return .none
        }
    }
}
