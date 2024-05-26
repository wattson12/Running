import Cache
import ComposableArchitecture
import CoreData
import DependenciesAdditions
import FeatureFlags
import Foundation

@Reducer
public struct SettingsFeature {
    @ObservableState
    public struct State: Equatable {
        var versionNumber: String = ""
        var buildNumber: String = ""
        var acknowledgements: IdentifiedArrayOf<Acknowledgement> = .acknowledgements

        @Shared(.featureFlag(.runDetail)) var runDetailEnabled: Bool = false
        @Shared(.featureFlag(FeatureFlagKey.history)) var historyEnabled: Bool = false
        @Shared(.featureFlag(.program)) var programEnabled: Bool = false

        var displayFeatureFlags: Bool { _displayFeatureFlags() }

        func _displayFeatureFlags(bundleInfo: [String: Any]? = Bundle.main.infoDictionary) -> Bool {
            @Dependency(\.processInfo) var processInfo
            let testflight = (bundleInfo?["IS_TESTFLIGHT_BUILD"] as? String) == "YES"
            let preview = processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != nil
            return testflight || preview
        }

        public init() {}
    }

    @CasePathable
    public enum Action: Equatable, BindableAction, ViewAction {
        @CasePathable
        public enum View: Equatable {
            case onAppear
            case deleteAllRunsTapped
        }

        case view(View)
        case binding(BindingAction<State>)
    }

    @Dependency(\.bundleInfo) var bundleInfo
    @Dependency(\.userDefaults) var userDefaults
    @Dependency(\.coreData) var coreData

    public init() {}

    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case let .view(action):
                return view(action, state: &state)
            case .binding:
                return .none
            }
        }
    }

    private func view(_ action: Action.View, state: inout State) -> EffectOf<Self> {
        switch action {
        case .onAppear:
            state.versionNumber = bundleInfo.shortVersion
            state.buildNumber = bundleInfo.version
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
