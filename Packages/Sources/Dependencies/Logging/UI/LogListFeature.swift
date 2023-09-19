import ComposableArchitecture
import Foundation

public struct LogListFeature: Reducer {
    public struct State: Equatable {
        var logs: [ActionLog] = []
    }

    public enum Action: Equatable {
        public enum View: Equatable {
            case onAppear
            case refreshButtonTapped
        }

        case view(View)
    }

    @Dependency(\.logStore) var logStore

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .view(action):
                return view(action, state: &state)
            }
        }
    }

    private func view(_ action: Action.View, state: inout State) -> EffectOf<Self> {
        switch action {
        case .onAppear:
            refreshLogs(&state)
            return .none
        case .refreshButtonTapped:
            refreshLogs(&state)
            return .none
        }
    }

    private func refreshLogs(_ state: inout State) {
        state.logs = logStore.logs()
    }
}
