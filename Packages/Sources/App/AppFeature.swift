import ComposableArchitecture
import FeatureFlags
import Foundation
import GoalList
import HealthKitServiceInterface
import History
import Permissions
import Repository
import RunList
import Settings

@Reducer
public struct AppFeature {
    @Reducer
    public struct Destination {
        public enum State: Equatable {
            case settings(SettingsFeature.State)
        }

        public enum Action: Equatable {
            case settings(SettingsFeature.Action)
        }

        public var body: some ReducerOf<Self> {
            Scope(state: /State.settings, action: /Action.settings, child: SettingsFeature.init)
        }
    }

    @ObservableState
    public struct State: Equatable {
        public enum Tab: Equatable, Hashable {
            case goals
            case runs
            case history
        }

        var permissions: PermissionsFeature.State?

        var tab: Tab
        var runList: RunListFeature.State
        var goalList: GoalListFeature.State
        var history: HistoryFeature.State?

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
    }

    public enum Action: Equatable {
        @CasePathable
        public enum View: Equatable {
            case onAppear
            case settingsButtonTapped
            case updateTab(State.Tab)
        }

        case view(View)
        case permissions(PermissionsFeature.Action)
        case runList(RunListFeature.Action)
        case goalList(GoalListFeature.Action)
        case history(HistoryFeature.Action)
        case deepLink(URL)
        case destination(PresentationAction<Destination.Action>)
    }

    public init() {}

    @Dependency(\.repository.goals) var goals
    @Dependency(\.repository.runningWorkouts) var runningWorkouts
    @Dependency(\.healthKit.observation) var observation
    @Dependency(\.userDefaults) var userDefaults
    @Dependency(\.featureFlags) var featureFlags

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .view(action):
                return view(action, state: &state)
            case let .permissions(action):
                return permissions(action, state: &state)
            case let .runList(action):
                return runList(action, state: &state)
            case .goalList:
                return .none
            case .history:
                return .none
            case let .deepLink(url):
                return deepLink(url: url, state: &state)
            case let .destination(action):
                return destination(action, state: &state)
            }
        }
        .ifLet(\.permissions, action: \.permissions) { PermissionsFeature() }
        .ifLet(\.history, action: \.history, then: HistoryFeature.init)
        .ifLet(\.$destination, action: \.destination, destination: Destination.init)

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
            state.history = featureFlags[.history] ? .init() : nil
            return .merge(
                state.runList.refresh().map(Action.runList),
                .run { _ in
                    try await observation.enableBackgroundDelivery()
                    try await observation.observeWorkouts()
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

    private func destination(_ action: PresentationAction<Destination.Action>, state: inout State) -> EffectOf<Self> {
        guard case let .presented(action) = action else { return .none }
        switch action {
        case let .settings(action):
            return settings(action, state: &state)
        }
    }

    private func settings(_ action: SettingsFeature.Action, state: inout State) -> EffectOf<Self> {
        guard case let .delegate(action) = action else { return .none }

        state.history = featureFlags[.history] ? .init() : nil
        return .none
    }
}
