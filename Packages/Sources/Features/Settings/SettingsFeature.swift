import ComposableArchitecture
import DependenciesAdditions
import Foundation
import Logging

public extension Bool {
    static var debugSectionVisibleDefaultValue: Bool {
        #if targetEnvironment(simulator)
            return false
        #else
            return false
        #endif
    }
}

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

        var debugSectionVisible: Bool
        var loggingDisplayed: Bool = false

        @PresentationState var destination: Destination.State?

        public init(debugSectionVisible: Bool = .debugSectionVisibleDefaultValue) {
            self.debugSectionVisible = debugSectionVisible
        }
    }

    public enum Action: Equatable {
        public enum View: Equatable {
            case onAppear
            case hiddenAreaGestureFired
            case showLoggingButtonTapped
            case loggingDisplayed(Bool)
        }

        case view(View)
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
            return .none
        case .hiddenAreaGestureFired:
            state.debugSectionVisible.toggle()
            return .none
        case .showLoggingButtonTapped:
            state.loggingDisplayed = true
            return .none
        case let .loggingDisplayed(displayed):
            state.loggingDisplayed = displayed
            return .none
        }
    }
}
