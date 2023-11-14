import ComposableArchitecture
import Foundation
import Model

@Reducer
public struct GoalDetailFeature {
    public struct State: Equatable {
        let goal: Goal
        var runs: [Run]?
        var emptyStateRuns: [Run]

        public init(
            goal: Goal,
            runs: [Run]? = nil,
            emptyStateRuns: [Run] = []
        ) {
            self.goal = goal
            self.runs = runs
            self.emptyStateRuns = emptyStateRuns
        }
    }

    public enum Action: Equatable {
        @CasePathable
        public enum View: Equatable {
            case onAppear
        }

        @CasePathable
        public enum Internal: Equatable {
            case runsFetched(TaskResult<[Run]>)
        }

        case view(View)
        case _internal(Internal)
    }

    @Dependency(\.calendar) var calendar
    @Dependency(\.date) var date
    @Dependency(\.repository.runningWorkouts) var runningWorkouts
    @Dependency(\.repository.goals) var goals
    @Dependency(\.uuid) var uuid

    public init() {}

    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case let .view(action):
                return view(action, state: &state)
            case let ._internal(action):
                return _internal(action, state: &state)
            }
        }
    }

    private func view(_ action: Action.View, state: inout State) -> Effect<Action> {
        switch action {
        case .onAppear:
            if let runsForGoal = try? runningWorkouts.runs(within: state.goal) {
                state.runs = runsForGoal
                updateEmptyStateRuns(state: &state)
            }

            return .run { [goal = state.goal] send in
                let result = await TaskResult {
                    _ = try await runningWorkouts.allRunningWorkouts.remote()
                    return try runningWorkouts.runs(within: goal)
                }
                await send(._internal(.runsFetched(result)))
            }
        }
    }

    private func _internal(_ action: Action.Internal, state: inout State) -> Effect<Action> {
        switch action {
        case let .runsFetched(.success(runs)):
            state.runs = runs
            updateEmptyStateRuns(state: &state)
            return .none
        case .runsFetched(.failure):
            return .none
        }
    }

    private func updateEmptyStateRuns(state: inout State) {
        guard state.runs?.isEmpty != false else { return }
        // skip recalculation if we populated empty state initially
        guard state.emptyStateRuns.isEmpty else { return }

        guard let range = state.goal.period.startAndEnd(in: calendar, now: date.now) else { return }
        let numberOfDaysInRangeComponents = calendar.dateComponents([.day], from: range.start, to: range.end)
        guard let numberOfDaysInRange = numberOfDaysInRangeComponents.day else { return }

        guard let goal = state.goal.target else { return }

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
        state.emptyStateRuns = runs
    }
}
