import ComposableArchitecture
import Model
import Repository
import SwiftUI

@Reducer
struct DebugAppFeature: Reducer {
    @ObservableState
    enum State: Equatable, Sendable {
        case initial
        case permissionRequired
        case runs(DebugRunListFeature.State)
    }

    @CasePathable
    enum Action: ViewAction, Sendable {
        @CasePathable
        enum View: Sendable {
            case onAppear
            case requestPermissionsButtonTapped
        }

        @CasePathable
        enum Internal: Sendable {
            case permissionsFetched(Result<AuthorizationRequestStatus, Error>)
            case permissionsRequested(Result<Bool, Error>)
        }

        case view(View)
        case _internal(Internal)
        case runs(DebugRunListFeature.Action)
    }

    @Dependency(\.repository.permissions) var permissions

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .view(action):
                return view(action, state: &state)
            case let ._internal(action):
                return _internal(action, state: &state)
            case .runs:
                return .none
            }
        }
        .ifCaseLet(\.runs, action: \.runs, then: DebugRunListFeature.init)
    }

    private func view(_ action: Action.View, state _: inout State) -> EffectOf<Self> {
        switch action {
        case .onAppear:
            return .run { send in
                let result = await Result {
                    try await permissions.authorizationRequestStatus()
                }
                await send(._internal(.permissionsFetched(result)))
            }
        case .requestPermissionsButtonTapped:
            return .run { send in
                let result = await Result {
                    try await permissions.requestAuthorization()
                    return true
                }
                await send(._internal(.permissionsRequested(result)))
            }
        }
    }

    private func _internal(_ action: Action.Internal, state: inout State) -> EffectOf<Self> {
        switch action {
        case let .permissionsFetched(.success(status)):
            switch status {
            case .shouldRequest:
                state = .permissionRequired
            case .requested:
                state = .runs(.init())
            case .unknown:
                break
            }
            return .none
        case .permissionsRequested(.success):
            state = .runs(.init())
            return .none
        case let .permissionsFetched(.failure(error)), let .permissionsRequested(.failure(error)):
            print(error)
            return .none
        }
    }
}

@ViewAction(for: DebugAppFeature.self)
struct DebugAppView: View {
    let store: StoreOf<DebugAppFeature>

    var body: some View {
        NavigationStack {
            Group {
                switch store.state {
                case .initial:
                    ProgressView()
                        .progressViewStyle(.circular)
                        .onAppear { send(.onAppear) }
                case .permissionRequired:
                    Button(
                        "Request Permissions",
                        action: {
                            send(.requestPermissionsButtonTapped)
                        }
                    )
                    .buttonStyle(.borderedProminent)
                case .runs:
                    if let store = store.scope(state: \.runs, action: \.runs) {
                        DebugRunListView(store: store)
                    }
                }
            }
            .navigationTitle("Debug")
        }
    }
}

#Preview("Permissions Required") {
    DebugAppView(
        store: .init(
            initialState: .initial,
            reducer: DebugAppFeature.init,
            withDependencies: {
                $0.repository.permissions._authorizationRequestStatus = { .shouldRequest }
            }
        )
    )
}

#Preview("Permission Granted") {
    DebugAppView(
        store: .init(
            initialState: .initial,
            reducer: DebugAppFeature.init,
            withDependencies: {
                $0.repository.permissions._authorizationRequestStatus = { .requested }
            }
        )
    )
}
