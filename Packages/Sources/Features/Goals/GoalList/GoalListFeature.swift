import ComposableArchitecture
import EditGoal
import Foundation
import GoalDetail
import Model
import Repository
import Widgets

struct GoalRow: Identifiable, Equatable {
    let goal: Goal
    let distance: Measurement<UnitLength>

    var id: String {
        let components: [String?] = [
            goal.period.rawValue,
            goal.target?.value.description,
            distance.value.description,
        ]

        return components
            .compactMap { $0 }
            .joined(separator: ".")
    }
}

@Reducer
public struct GoalListFeature {
    @Reducer
    public struct Destination {
        public enum State: Equatable {
            case editGoal(EditGoalFeature.State)
            case detail(GoalDetailFeature.State)
        }

        public enum Action: Equatable {
            case editGoal(EditGoalFeature.Action)
            case detail(GoalDetailFeature.Action)
        }

        public var body: some Reducer<State, Action> {
            Scope(
                state: /State.editGoal,
                action: /Action.editGoal,
                child: EditGoalFeature.init
            )
            Scope(
                state: /State.detail,
                action: /Action.detail,
                child: GoalDetailFeature.init
            )
        }
    }

    @ObservableState
    public struct State: Equatable {
        var weeklyGoal: Goal?
        var weeklyRuns: [Run] = []
        var yearlyGoal: Goal?
        var yearlyRuns: [Run] = []
        var monthlyGoal: Goal?
        var monthlyRuns: [Run] = []

        var rows: IdentifiedArrayOf<GoalRow> = []

        @PresentationState var destination: Destination.State?

        public init(
            weeklyGoal: Goal? = nil,
            monthlyGoal: Goal? = nil,
            yearlyGoal: Goal? = nil
        ) {
            self.weeklyGoal = weeklyGoal
            self.yearlyGoal = yearlyGoal
            self.monthlyGoal = monthlyGoal
        }

        init(
            weeklyGoal: Goal? = nil,
            weeklyRuns: [Run] = [],
            yearlyGoal: Goal? = nil,
            yearlyRuns: [Run] = [],
            monthlyGoal: Goal? = nil,
            monthlyRuns: [Run] = [],
            destination: Destination.State? = nil
        ) {
            self.weeklyGoal = weeklyGoal
            self.weeklyRuns = weeklyRuns
            self.yearlyGoal = yearlyGoal
            self.yearlyRuns = yearlyRuns
            self.monthlyGoal = monthlyGoal
            self.monthlyRuns = monthlyRuns
            self.destination = destination
        }

        public mutating func refresh(
            goals: Goals,
            runningWorkouts: RunningWorkouts
        ) {
            let periods: [Goal.Period] = [.weekly, .monthly, .yearly]
            for period in periods {
                updateGoalAndRuns(
                    for: period,
                    goals: goals,
                    runningWorkouts: runningWorkouts
                )
            }

            refreshRows()
        }

        mutating func refreshRows() {
            let weekly: (Goal?, Measurement<UnitLength>) = (
                weeklyGoal,
                weeklyRuns.map(\.distance)
                    .reduce(.init(value: 0, unit: .secondaryUnit()), +)
            )
            let monthly: (Goal?, Measurement<UnitLength>) = (
                monthlyGoal,
                monthlyRuns.map(\.distance)
                    .reduce(.init(value: 0, unit: .secondaryUnit()), +)
            )
            let yearly: (Goal?, Measurement<UnitLength>) = (
                yearlyGoal,
                yearlyRuns.map(\.distance)
                    .reduce(.init(value: 0, unit: .secondaryUnit()), +)
            )

            let rowArray: [GoalRow] = [weekly, monthly, yearly].compactMap { goal, distance in
                guard let goal else { return nil }
                return .init(
                    goal: goal,
                    distance: distance
                )
            }
            rows = .init(uniqueElements: rowArray)
        }

        private mutating func updateGoalAndRuns(
            for period: Goal.Period,
            goals: Goals,
            runningWorkouts: RunningWorkouts
        ) {
            do {
                let goal = try goals.goal(in: period)
                self[keyPath: goalKeyPath(for: period)] = goal
                self[keyPath: runsKeyPath(for: period)] = try runningWorkouts.runs(within: goal)
            } catch {
                self[keyPath: goalKeyPath(for: period)] = nil
                self[keyPath: runsKeyPath(for: period)] = []
            }
        }

        private func goalKeyPath(for period: Goal.Period) -> WritableKeyPath<State, Goal?> {
            switch period {
            case .weekly:
                return \.weeklyGoal
            case .monthly:
                return \.monthlyGoal
            case .yearly:
                return \.yearlyGoal
            }
        }

        private func runsKeyPath(for period: Goal.Period) -> WritableKeyPath<State, [Run]> {
            switch period {
            case .weekly:
                return \.weeklyRuns
            case .monthly:
                return \.monthlyRuns
            case .yearly:
                return \.yearlyRuns
            }
        }

        public mutating func handleDeepLink(route: GoalListRoute) {
            // deep linking to a different destination than is currently open shows a blank screen
            guard destination == nil else { return }

            let goal: Goal?
            switch route.period {
            case .weekly:
                goal = weeklyGoal
            case .monthly:
                goal = monthlyGoal
            case .yearly:
                goal = yearlyGoal
            }

            guard let goal else { return }

            if let action = route.action {
                switch action {
                case .edit:
                    destination = .editGoal(.init(goal: goal))
                }
            } else {
                destination = .detail(.init(goal: goal))
            }
        }
    }

    public enum Action: Equatable {
        public enum View: Equatable {
            case onAppear
            case goalTapped(Goal)
            case editTapped(Goal)
        }

        case view(View)
        case destination(PresentationAction<Destination.Action>)
    }

    public init() {}

    @Dependency(\.repository.goals) var goals
    @Dependency(\.repository.runningWorkouts) var runningWorkouts
    @Dependency(\.widget) var widget

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .view(action):
                return view(action, state: &state)
            case let .destination(action):
                return destination(action, state: &state)
            }
        }
        .ifLet(\.$destination, action: \.destination) { Destination() }
    }

    private func view(_ action: Action.View, state: inout State) -> Effect<Action> {
        switch action {
        case .onAppear:
            state.refresh(goals: goals, runningWorkouts: runningWorkouts)
            return .run { _ in widget.reloadAllTimelines() }
        case let .goalTapped(goal):
            if goal.target == nil {
                state.destination = .editGoal(.init(goal: goal))
            } else {
                state.destination = .detail(.init(goal: goal))
            }
            return .none
        case let .editTapped(goal):
            state.destination = .editGoal(.init(goal: goal))
            return .none
        }
    }

    private func destination(_ action: PresentationAction<Destination.Action>, state: inout State) -> Effect<Action> {
        guard case let .presented(action) = action else { return .none }
        switch action {
        case let .editGoal(action):
            return editGoal(action, state: &state)
        case let .detail(action):
            return detail(action, state: &state)
        }
    }

    private func editGoal(_ action: EditGoalFeature.Action, state: inout State) -> Effect<Action> {
        guard case let .delegate(action) = action else { return .none }
        switch action {
        case let .goalUpdated(goal):
            switch goal.period {
            case .weekly:
                state.weeklyGoal = goal
            case .monthly:
                state.monthlyGoal = goal
            case .yearly:
                state.yearlyGoal = goal
            }

            state.destination = nil

            state.refreshRows()

            return .run { _ in
                try goals.update(goal: goal)
                widget.reloadAllTimelines()
            }
        case let .goalCleared(period):
            let goal: Goal?
            switch period {
            case .weekly:
                state.weeklyGoal?.target = nil
                goal = state.weeklyGoal
            case .monthly:
                state.monthlyGoal?.target = nil
                goal = state.monthlyGoal
            case .yearly:
                state.yearlyGoal?.target = nil
                goal = state.yearlyGoal
            }

            state.destination = nil

            state.refreshRows()

            guard let goal else { return .none }
            return .run { [goal] _ in
                try goals.update(goal: goal)
                widget.reloadAllTimelines()
            }
        }
    }

    private func detail(_: GoalDetailFeature.Action, state _: inout State) -> Effect<Action> {
        .none
    }
}
