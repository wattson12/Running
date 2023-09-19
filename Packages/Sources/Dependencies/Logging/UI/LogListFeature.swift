import ComposableArchitecture
import Foundation

public struct LogListFeature: Reducer {
    public struct Destination: Reducer {
        public enum State: Equatable {
            case detail(LogDetailFeature.State)
        }

        public enum Action: Equatable {
            case detail(LogDetailFeature.Action)
        }

        public var body: some ReducerOf<Self> {
            Scope(state: /State.detail, action: /Action.detail, child: LogDetailFeature.init)
        }
    }

    public struct State: Equatable {
        var logs: [ActionLog] = []
        @PresentationState var destination: Destination.State?
    }

    public enum Action: Equatable {
        public enum View: Equatable {
            case onAppear
            case refreshButtonTapped
            case logTapped(ActionLog)
        }

        case view(View)
        case destination(PresentationAction<Destination.Action>)
    }

    @Dependency(\.logStore) var logStore

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
            refreshLogs(&state)
            return .none
        case .refreshButtonTapped:
            refreshLogs(&state)
            return .none
        case let .logTapped(log):
            state.destination = .detail(log)
            return .none
        }
    }

    private func refreshLogs(_ state: inout State) {
        state.logs = logStore.logs()
    }
}
