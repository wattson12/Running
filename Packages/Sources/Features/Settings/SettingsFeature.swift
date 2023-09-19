import ComposableArchitecture
import DependenciesAdditions
import Foundation
import Logging

public struct SettingsFeature: Reducer {
    public struct Destination: Reducer {
        public enum State: Equatable {
            case logging(LogListFeature.State)
        }

        public enum Action: Equatable {
            case logging(LogListFeature.Action)
        }

        public var body: some ReducerOf<Self> {
            Scope(state: /State.logging, action: /Action.logging, child: LogListFeature.init)
        }
    }

    public struct State: Equatable {
        var versionNumber: String = ""
        var buildNumber: String = ""
        var acknowledgements: IdentifiedArrayOf<Acknowledgement> = .acknowledgements

        var debugSectionVisible: Bool = false
        var debugTabVisible: Bool = false

        var loggingDisplayed: Bool = false

        @PresentationState var destination: Destination.State?

        public init() {}
    }

    public enum Action: Equatable {
        public enum View: Equatable {
            case onAppear
            case hiddenAreaGestureFired
            case setDebugTabVisible(Bool)
            case showLoggingButtonTapped
            case loggingDisplayed(Bool)
        }

        public enum Delegate: Equatable {
            case setDebugTabVisibility(Bool)
        }

        case view(View)
        case delegate(Delegate)
        case destination(PresentationAction<Destination.Action>)
    }

    @Dependency(\.bundleInfo) var bundleInfo
    @Dependency(\.userDefaults) var userDefaults

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .view(action):
                return view(action, state: &state)
            case .delegate:
                return .none
            case .destination:
                return .none
            }
        }
        .ifLet(\.$destination, action: /Action.destination, destination: Destination.init)
    }

    private func view(_ action: Action.View, state: inout State) -> EffectOf<Self> {
        switch action {
        case .onAppear:
            state.versionNumber = bundleInfo.shortVersion
            state.buildNumber = bundleInfo.version
            state.debugTabVisible = userDefaults.bool(forKey: "debug_tab_visible") == true
            return .none
        case .hiddenAreaGestureFired:
            state.debugSectionVisible.toggle()
            return .none
        case let .setDebugTabVisible(visible):
            state.debugTabVisible = visible
            userDefaults.set(visible, forKey: "debug_tab_visible")
            return .send(.delegate(.setDebugTabVisibility(visible)))
        case .showLoggingButtonTapped:
            state.loggingDisplayed = true
//            state.destination = .logging(.init())
            return .none
        case let .loggingDisplayed(displayed):
            state.loggingDisplayed = displayed
            return .none
        }
    }
}
