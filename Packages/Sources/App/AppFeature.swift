import ComposableArchitecture
import Foundation
import GoalList
import HealthKitServiceInterface
import Permissions
import Repository
import RunList
import Settings

public struct AppFeature: Reducer {
    public struct Destination: Reducer {
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

    public struct State: Equatable {
        public enum Tab: Equatable, Hashable {
            case goals
            case runs
            case debug
        }

        var permissions: PermissionsFeature.State?

        var tab: Tab
        var runList: RunListFeature.State
        var goalList: GoalListFeature.State
        var debug: DebugFeature.State
        var debugTabVisible: Bool = false

        @PresentationState var destination: Destination.State?

        init(
            permissions: PermissionsFeature.State? = .init(state: .initial),
            tab: Tab = .goals,
            runList: RunListFeature.State = .init(),
            goalList: GoalListFeature.State = .init(),
            debug: DebugFeature.State = .init(),
            destination: Destination.State? = nil,
            debugTabVisible: Bool = false
        ) {
            self.permissions = permissions
            self.tab = tab
            self.runList = runList
            self.goalList = goalList
            self.debug = debug
            self.destination = destination
            self.debugTabVisible = debugTabVisible
        }

        public init() {
            permissions = .init(state: .initial)
            tab = .goals
            runList = .init()
            goalList = .init()
            debug = .init()
        }
    }

    public enum Action: Equatable {
        public enum View: Equatable {
            case onAppear
            case settingsButtonTapped
            case updateTab(State.Tab)
        }

        case view(View)
        case permissions(PermissionsFeature.Action)
        case runList(RunListFeature.Action)
        case goalList(GoalListFeature.Action)
        case debug(DebugFeature.Action)
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
            case let .permissions(action):
                return permissions(action, state: &state)
            case let .runList(action):
                return runList(action, state: &state)
            case .goalList:
                return .none
            case .debug:
                return .none
            case let .deepLink(url):
                return deepLink(url: url, state: &state)
            case let .destination(action):
                return destination(action, state: &state)
            }
        }
        .ifLet(\.permissions, action: /Action.permissions) { PermissionsFeature() }
        .ifLet(\.$destination, action: /Action.destination, destination: Destination.init)

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

        Scope(
            state: \.debug,
            action: /Action.debug,
            child: DebugFeature.init
        )
    }

    private func view(_ action: Action.View, state: inout State) -> Effect<Action> {
        switch action {
        case .onAppear:
            state.debugTabVisible = userDefaults.bool(forKey: "debug_tab_visible") == true
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
        switch action {
        case let .setDebugTabVisibility(visible):
            state.debugTabVisible = visible
            return .none
        }
    }
}
