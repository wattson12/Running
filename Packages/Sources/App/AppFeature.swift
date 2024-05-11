import Combine
import ComposableArchitecture
import Foundation
import GoalList
import HealthKitServiceInterface
import History
import Permissions
import Program
import Repository
import RunList
import Settings

@Reducer
public struct AppFeature {
    @Reducer(state: .equatable, action: .equatable)
    public enum Destination {
        case settings(SettingsFeature)
    }

    @ObservableState
    public struct State: Equatable {
        public enum Tab: Equatable, Hashable {
            case goals
            case runs
            case history
            case program
        }

        var permissions: PermissionsFeature.State?

        var tab: Tab
        var runList: RunListFeature.State
        var goalList: GoalListFeature.State
        var history: HistoryFeature.State?
        var program: PlaceholderProgramFeature.State?

        @Shared(.appStorage("history_feature")) var showHistory: Bool = false
        @Shared(.appStorage("program_feature")) var showProgram: Bool = false

        @Presents var destination: Destination.State?

        init(
            permissions: PermissionsFeature.State? = .init(state: .initial),
            tab: Tab = .goals,
            runList: RunListFeature.State = .init(),
            goalList: GoalListFeature.State = .init(),
            history: HistoryFeature.State? = nil,
            destination: Destination.State? = nil
        ) {
            self.permissions = permissions
            self.tab = tab
            self.runList = runList
            self.goalList = goalList
            self.history = history
            self.destination = destination
        }

        public init() {
            permissions = .init(state: .initial)
            tab = .goals
            runList = .init()
            goalList = .init()
            history = nil
        }

        mutating func refreshFeatureFlagState() {
            history = showHistory ? .init() : nil
            program = showProgram ? .init() : nil
        }
    }

    @CasePathable
    public enum Action: Equatable, ViewAction {
        @CasePathable
        public enum View: Equatable {
            case onAppear
            case settingsButtonTapped
            case updateTab(State.Tab)
        }

        @CasePathable
        public enum Internal: Equatable {
            case refreshFeatureFlagState
        }

        case view(View)
        case _internal(Internal)
        case permissions(PermissionsFeature.Action)
        case runList(RunListFeature.Action)
        case goalList(GoalListFeature.Action)
        case history(HistoryFeature.Action)
        case program(PlaceholderProgramFeature.Action)
        case deepLink(URL)
        case destination(PresentationAction<Destination.Action>)
    }

    public init() {}

    @Dependency(\.repository.goals) var goals
    @Dependency(\.repository.runningWorkouts) var runningWorkouts
    @Dependency(\.healthKit.observation) var observation
    @Dependency(\.userDefaults) var userDefaults

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .view(action):
                return view(action, state: &state)
            case let ._internal(action):
                return _internal(action, state: &state)
            case let .permissions(action):
                return permissions(action, state: &state)
            case let .runList(action):
                return runList(action, state: &state)
            case .goalList:
                return .none
            case .history:
                return .none
            case .program:
                return .none
            case let .deepLink(url):
                return deepLink(url: url, state: &state)
            case .destination:
                return .none
            }
        }
        .ifLet(\.permissions, action: \.permissions) { PermissionsFeature() }
        .ifLet(\.history, action: \.history, then: HistoryFeature.init)
        .ifLet(\.program, action: \.program, then: PlaceholderProgramFeature.init)
        .ifLet(\.$destination, action: \.destination)

        Scope(
            state: \.runList,
            action: /Action.runList,
            child: RunListFeature.init
        )

        Scope(
            state: \.goalList,
            action: /Action.goalList,
            child: GoalListFeature.init
        )
    }

    private func view(_ action: Action.View, state: inout State) -> Effect<Action> {
        switch action {
        case .onAppear:
            state.refreshFeatureFlagState()

            return .merge(
                state.runList.refresh().map(Action.runList),
                .run { _ in
                    try await observation.enableBackgroundDelivery()
                    try await observation.observeWorkouts()
                },
                .publisher {
                    Publishers.Merge(
                        state.$showProgram.publisher.dropFirst(),
                        state.$showHistory.publisher.dropFirst()
                    )
                    .map { _ in ._internal(.refreshFeatureFlagState) }
                }
            )
        case .settingsButtonTapped:
            state.destination = .settings(.init())
            return .none
        case let .updateTab(tab):
            state.tab = tab
            return .none
        }
    }

    private func _internal(_ action: Action.Internal, state: inout State) -> EffectOf<Self> {
        switch action {
        case .refreshFeatureFlagState:
            state.refreshFeatureFlagState()
            return .none
        }
    }

    private func runList(_ action: RunListFeature.Action, state: inout State) -> Effect<Action> {
        guard case let .delegate(action) = action else { return .none }
        switch action {
        case .runsRefreshed:
            state.goalList.refresh(
                goals: goals,
                runningWorkouts: runningWorkouts
            )
            return .none
        }
    }

    private func permissions(_ action: PermissionsFeature.Action, state: inout State) -> Effect<Action> {
        guard case let .delegate(action) = action else { return .none }
        switch action {
        case .permissionsAvailable:
            state.permissions = nil
            return .none
        }
    }

    private func deepLink(url: URL, state: inout State) -> EffectOf<Self> {
        guard let route = try? appRouter.match(url: url) else { return .none }
        switch route {
        case let .goals(route):
            state.tab = .goals
            state.goalList.handleDeepLink(route: route)
        case .runs:
            state.tab = .runs
        }
        return .none
    }
}
