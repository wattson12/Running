import ComposableArchitecture
import Foundation
import Model

public struct RunDetailFeature: Reducer {
    public struct State: Equatable {
        var run: Run
        var isLoading: Bool

        public init(
            run: Run
        ) {
            self.run = run
            isLoading = false
        }
    }

    public enum Action: Equatable {
        public enum View: Equatable {
            case onAppear
        }

        public enum Internal: Equatable {
            case runDetailFetched(TaskResult<Run>)
        }

        case view(View)
        case _internal(Internal)
    }

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .view(action):
                return view(action, state: &state)
            case let ._internal(action):
                return _internal(action, state: &state)
            }
        }
    }

    private func view(_ action: Action.View, state _: inout State) -> EffectOf<Self> {
        switch action {
        case .onAppear:
            return .none
        }
    }

    private func _internal(_ action: Action.Internal, state: inout State) -> EffectOf<Self> {
        switch action {
        case let .runDetailFetched(.success(run)):
            state.run = run
            state.isLoading = false
            return .none
        case .runDetailFetched(.failure):
            state.isLoading = false
            return .none
        }
    }
}
