import ComposableArchitecture
import DependenciesAdditions
import FeatureFlags
import Foundation
import Model
import Repository
import RunDetail
import Widgets

extension String {
    static let initialImportCompleted: Self = "initial_import_completed"
}

@dynamicMemberLookup
public struct RunState: Identifiable, Equatable {
    let run: Run
    let relativeStartDate: String

    init(run: Run) {
        self.run = run

        @Dependency(\.date) var dateGenerator

        // show relative dates within the last 2 weeks only
        if dateGenerator.now.timeIntervalSince(run.startDate) > 14 * 24 * 60 * 60 {
            self.relativeStartDate = DateFormatter.run.string(from: run.startDate)
        } else {
            self.relativeStartDate = RelativeDateTimeFormatter.run.localizedString(for: run.startDate, relativeTo: dateGenerator.now)
        }
    }

    public var id: Run.ID {
        run.id
    }

    subscript<T>(dynamicMember keyPath: KeyPath<Run, T>) -> T {
        run[keyPath: keyPath]
    }
}

@Reducer
public struct RunListFeature {
    @Reducer(state: .equatable, action: .equatable)
    public enum Destination {
        case detail(RunDetailFeature)
    }

    @ObservableState
    public struct State: Equatable {
        var runs: IdentifiedArrayOf<RunState> = []
        var isInitialImport: Bool = false
        var isLoading: Bool = false
        @Shared(.featureFlag(.runDetail)) var runDetailEnabled: Bool = false
        @Presents var destination: Destination.State?

        public init(
            runs: [Run] = []
        ) {
            self.runs = .init(uniqueElements: runs.map(RunState.init))
        }

        init(
            runs: [Run] = [],
            isInitialImport: Bool = false,
            isLoading: Bool = false,
            destination: Destination.State? = nil
        ) {
            self.runs = .init(uniqueElements: runs.map(RunState.init))
            self.isInitialImport = isInitialImport
            self.isLoading = isLoading
            self.destination = destination
        }
    }

    @CasePathable
    public enum Action: Equatable, ViewAction {
        @CasePathable
        public enum View: Equatable {
            case onAppear
            case runTapped(Run)
        }

        @CasePathable
        public enum Internal: Equatable {
            case runsFetched(TaskResult<[Run]>)
        }

        @CasePathable
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
        .ifLet(\.$destination, action: \.destination)
    }

    private func view(_ action: Action.View, state: inout State) -> Effect<Action> {
        switch action {
        case .onAppear:
            return state.refresh()
        case let .runTapped(run):
            guard state.runDetailEnabled else { return .none }
            state.destination = .detail(.init(run: run))
            return .none
        }
    }

    private func _internal(_ action: Action.Internal, state: inout State) -> Effect<Action> {
        switch action {
        case let .runsFetched(.success(runs)):
            clearInitialImportFlag(state: &state)
            state.isLoading = false
            state.runs = .init(uniqueElements: runs.map(RunState.init))
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

    private func destination(_ action: PresentationAction<Destination.Action>, state: inout State) -> EffectOf<Self> {
        guard case let .presented(action) = action else { return .none }
        switch action {
        case let .detail(action):
            return detail(action, state: &state)
        }
    }

    private func detail(_ action: RunDetailFeature.Action, state: inout State) -> EffectOf<Self> {
        guard case let .delegate(action) = action else { return .none }
        switch action {
        case let .runDetailFetched(run):
            state.runs[id: run.id] = .init(run: run)
            return .none
        }
    }
}
