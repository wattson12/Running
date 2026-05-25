import ComposableArchitecture
import Foundation
import Model

@Reducer
public struct PermissionsFeature: Sendable {
    public struct Empty: Equatable, Sendable {
        init(_ _: Void) {}
    }

    @ObservableState
    public struct State: Equatable, Sendable {
        public enum InnerState: Int, Equatable, Sendable {
            case initial
            case requestPermissions
            case healthKitNotAvailable
        }

        var state: InnerState

        public init(state: InnerState) {
            self.state = state
        }
    }

    @CasePathable
    public enum Action: ViewAction, Sendable {
        @CasePathable
        public enum View: Sendable {
            case onAppear
            case requestPermissionsButtonTapped
        }

        @CasePathable
        public enum Internal: Sendable {
            case requestPermissionsCompleted(Result<Empty, Error>)
            case authorizationRequestStatusCompleted(Result<AuthorizationRequestStatus, Error>)
        }

        @CasePathable
        public enum Delegate: Sendable {
            case permissionsAvailable
        }

        case view(View)
        case _internal(Internal)
        case delegate(Delegate)
    }

    public init() {}

    @Dependency(\.repository.permissions) var permissions
    @Dependency(\.repository.support) var support

    public var body: some Reducer<State, Action> {
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

    private func view(_ action: Action.View, state: inout State) -> Effect<Action> {
        switch action {
        case .onAppear:
            return validatePermissions(state: &state)
        case .requestPermissionsButtonTapped:
            return .run { send in
                let result = await Result { try await permissions.requestAuthorization() }
                await send(._internal(.requestPermissionsCompleted(result.map(Empty.init))))
            }
        }
    }

    private func _internal(_ action: Action.Internal, state: inout State) -> Effect<Action> {
        switch action {
        case .requestPermissionsCompleted(.success):
            return validatePermissions(state: &state)
        case .requestPermissionsCompleted(.failure):
            return .none
        case let .authorizationRequestStatusCompleted(.success(status)):
            switch status {
            case .shouldRequest, .unknown:
                state.state = .requestPermissions
                return .none
            case .requested:
                return .send(.delegate(.permissionsAvailable))
            }
        case .authorizationRequestStatusCompleted(.failure):
            state.state = .requestPermissions
            return .none
        }
    }

    private func validatePermissions(state: inout State) -> Effect<Action> {
        guard support.isHealthKitDataAvailable() else {
            state.state = .healthKitNotAvailable
            return .none
        }

        return .run { send in
            let result = await Result { try await permissions.authorizationRequestStatus() }
            await send(._internal(.authorizationRequestStatusCompleted(result)))
        }
    }
}
