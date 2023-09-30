import ComposableArchitecture
import DependenciesAdditions
import Foundation
import Model
import Repository
import RunDetail
import Widgets

extension String {
    static let initialImportCompleted: Self = "initial_import_completed"
}

public struct RunListFeature: Reducer {
    public struct Destination: Reducer {
        public enum State: Equatable {
            case detail(RunDetailFeature.State)
        }

        public enum Action: Equatable {
            case detail(RunDetailFeature.Action)
        }

        public var body: some ReducerOf<Self> {
            Scope(state: /State.detail, action: /Action.detail, child: RunDetailFeature.init)
        }
    }

    public struct State: Equatable {
        var sections: [RunSection] = []
        var isInitialImport: Bool = false
        var isLoading: Bool = false
        @PresentationState var destination: Destination.State?

        public init(
            sections: [RunSection] = []
        ) {
            self.sections = sections
        }
    }

    public enum Action: Equatable {
        public enum View: Equatable {
            case onAppear
            case runTapped(Run)
        }

        public enum Internal: Equatable {
            case runsFetched(TaskResult<[Run]>)
        }

        public enum Delegate: Equatable {
            case runsRefreshed
        }

        case view(View)
        case _internal(Internal)
        case delegate(Delegate)
        case destination(PresentationAction<Destination.Action>)
    }

    public init() {}

    @Dependency(\.userDefaults) var userDefaults
    @Dependency(\.widget) var widget

    public var body: some ReducerOf<Self> {
        Reduce<State, Action> { state, action in
            switch action {
            case let .view(action):
                return view(action, state: &state)
            case let ._internal(action):
                return _internal(action, state: &state)
            case .delegate:
                return .none
            case let .destination(action):
                return destination(action, state: &state)
            }
        }
        .ifLet(\.$destination, action: /Action.destination, destination: Destination.init)
    }

    private func view(_ action: Action.View, state: inout State) -> Effect<Action> {
        switch action {
        case .onAppear:
            return state.refresh()
        case let .runTapped(run):
            state.destination = .detail(.init(run: run))
            return .none
        }
    }

    private func _internal(_ action: Action.Internal, state: inout State) -> Effect<Action> {
        switch action {
        case let .runsFetched(.success(runs)):
            clearInitialImportFlag(state: &state)
            state.isLoading = false
            state.setSections(from: runs)
            return .merge(
                .run { _ in widget.reloadAllTimelines() },
                .send(.delegate(.runsRefreshed))
            )
        case .runsFetched(.failure):
            clearInitialImportFlag(state: &state)
            state.isLoading = false
            return .none
        }
    }

    private func clearInitialImportFlag(state: inout State) {
        guard state.isInitialImport else { return }

        userDefaults.set(true, forKey: .initialImportCompleted)
        state.isInitialImport = false
    }

    private func destination(_ action: PresentationAction<Destination.Action>, state _: inout State) -> EffectOf<Self> {
        guard case let .presented(action) = action else { return .none }
        switch action {
        case .detail:
            return .none
        }
    }
}
