import ComposableArchitecture
import Foundation
import Model
import Repository

@Reducer
public struct EditGoalFeature {
    @ObservableState
    public struct State: Equatable {
        let period: Goal.Period
        let initialGoal: Goal

        var target: String = "50"
        var targetMeasurement: Measurement<UnitLength>?

        public init(
            goal: Goal
        ) {
            period = goal.period
            initialGoal = goal
        }
    }

    @CasePathable
    public enum Action: Equatable {
        @CasePathable
        public enum View: Equatable {
            case onAppear
            case targetUpdated(String)
            case validateTarget
            case saveButtonTapped
            case clearButtonTapped
        }

        @CasePathable
        public enum Delegate: Equatable {
            case goalUpdated(Goal)
            case goalCleared(Goal.Period)
        }

        case view(View)
        case delegate(Delegate)
    }

    public init() {}

    @Dependency(\.locale) var locale

    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case let .view(action):
                return view(action, state: &state)
            case .delegate:
                return .none
            }
        }
    }

    private func view(_ action: Action.View, state: inout State) -> Effect<Action> {
        switch action {
        case .onAppear:
            state.targetMeasurement = state.initialGoal.target

            if let target = state.initialGoal.target {
                let targetValue = target.converted(to: .primaryUnit(locale: locale)).value
                state.target = targetValue.description
            }

            updateTargetMeasurement(&state)
            return .none
        case let .targetUpdated(target):
            state.target = target
            return .none
        case .validateTarget:
            if Double(state.target) == nil {
                state.target = state.target.trimmingCharacters(in: CharacterSet.decimalDigits.inverted)
                updateTargetMeasurement(&state)
            } else {
                updateTargetMeasurement(&state)
            }
            return .none
        case .saveButtonTapped:
            let updatedGoal: Goal = .init(
                period: state.period,
                target: state.targetMeasurement
            )

            return .send(.delegate(.goalUpdated(updatedGoal)))
        case .clearButtonTapped:
            return .send(.delegate(.goalCleared(state.period)))
        }
    }

    private func updateTargetMeasurement(_ state: inout State) {
        guard let targetValue = Double(state.target) else { return }
        state.targetMeasurement = .init(value: targetValue, unit: .primaryUnit(locale: locale))
    }
}
