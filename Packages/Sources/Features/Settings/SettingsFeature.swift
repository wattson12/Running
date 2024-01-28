import Cache
import ComposableArchitecture
import CoreData
import DependenciesAdditions
import FeatureFlags
import Foundation
import Logging

@Reducer
public struct SettingsFeature {
    @Reducer
    public struct Destination {
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

    @ObservableState
    public struct State: Equatable {
        var versionNumber: String = ""
        var buildNumber: String = ""
        var acknowledgements: IdentifiedArrayOf<Acknowledgement> = .acknowledgements

        var loggingDisplayed: Bool = false

        var showRunDetailFeatureFlag: Bool = false

        @Presents var destination: Destination.State?

        public init() {}
    }

    public enum Action: Equatable, BindableAction {
        public enum View: Equatable {
            case onAppear
            case showLoggingButtonTapped
            case loggingDisplayed(Bool)
            case deleteAllRunsTapped
        }

        case view(View)
        case binding(BindingAction<State>)
        case destination(PresentationAction<Destination.Action>)
    }

    @Dependency(\.bundleInfo) var bundleInfo
    @Dependency(\.userDefaults) var userDefaults
    @Dependency(\.featureFlags) var featureFlags
    @Dependency(\.coreData) var coreData

    public init() {}

    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case let .view(action):
                return view(action, state: &state)
            case .binding(\.showRunDetailFeatureFlag):
                featureFlags[.showRunDetail] = state.showRunDetailFeatureFlag
                return .none
            case .binding:
                return .none
            case .destination:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination, destination: Destination.init)
    }

    private func view(_ action: Action.View, state: inout State) -> EffectOf<Self> {
        switch action {
        case .onAppear:
            state.versionNumber = bundleInfo.shortVersion
            state.buildNumber = bundleInfo.version
            state.showRunDetailFeatureFlag = featureFlags[.showRunDetail]
            return .none
        case .showLoggingButtonTapped:
            state.loggingDisplayed = true
            return .none
        case let .loggingDisplayed(displayed):
            state.loggingDisplayed = displayed
            return .none
        case .deleteAllRunsTapped:
            return .run { _ in
                try coreData.performWork { context in
                    let allRunsFetchRequest = RunEntity.makeFetchRequest()
                    let allRuns = try context.fetch(allRunsFetchRequest)
                    print("deleting", allRuns.count, "runs")
                    for run in allRuns {
                        context.delete(run)
                    }
                    try context.save()
                }
            }
        }
    }
}
