import ComposableArchitecture
import Foundation
import Model
import Repository

@Reducer
public struct RunDetailFeature {
    @ObservableState
    public struct State: Equatable {
        var run: Run
        var isLoading: Bool

        public init(
            run: Run
        ) {
            self.run = run
            isLoading = false
        }

        init(
            run: Run,
            isLoading: Bool
        ) {
            self.run = run
            self.isLoading = isLoading
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

    @Dependency(\.repository.runningWorkouts) var runningWorkouts

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

    private func view(_ action: Action.View, state: inout State) -> EffectOf<Self> {
        switch action {
        case .onAppear:
            state.isLoading = state.run.detail == nil
            return .run { [id = state.run.id] send in
                let result = await TaskResult { try await runningWorkouts.detail(for: id) }
                await send(._internal(.runDetailFetched(result)))
            }
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
