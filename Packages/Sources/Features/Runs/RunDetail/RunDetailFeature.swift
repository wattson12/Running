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

        var splits: [Split]?

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

    @CasePathable
    public enum Action: Equatable {
        @CasePathable
        public enum View: Equatable {
            case onAppear
        }

        @CasePathable
        public enum Internal: Equatable {
            case runDetailFetched(TaskResult<Run>)
        }

        @CasePathable
        public enum Delegate: Equatable {
            case runDetailFetched(Run)
        }

        case view(View)
        case _internal(Internal)
        case delegate(Delegate)
    }

    public init() {}

    @Dependency(\.repository.runningWorkouts) var runningWorkouts
    @Dependency(\.locale) var locale

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .view(action):
                return view(action, state: &state)
            case let ._internal(action):
                return _internal(action, state: &state)
            case .delegate:
                return .none
            }
        }
    }

    private func view(_ action: Action.View, state: inout State) -> EffectOf<Self> {
        switch action {
        case .onAppear:
            state.isLoading = state.run.detail == nil

            return .run { [id = state.run.id] send in
                if let cachedRun = runningWorkouts.cachedRun(for: id) {
                    await send(._internal(.runDetailFetched(.success(cachedRun))))
                }

                let result = await TaskResult { try await runningWorkouts.detail(for: id) }
                await send(._internal(.runDetailFetched(result)))
            }
        }
    }

    private func _internal(_ action: Action.Internal, state: inout State) -> EffectOf<Self> {
        switch action {
        case let .runDetailFetched(.success(run)):
            state.run = run
            state.splits = state.run.detail?.distanceSamples.splits(locale: locale)
            state.isLoading = run.detail == nil
            return .send(.delegate(.runDetailFetched(run)))
        case .runDetailFetched(.failure):
            state.isLoading = false
            return .none
        }
    }
}
