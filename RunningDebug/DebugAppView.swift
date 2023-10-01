import ComposableArchitecture
import Model
import Repository
import SwiftUI

struct DebugAppFeature: Reducer {
    enum State: Equatable {
        case initial
        case permissionRequired
        case runs(DebugRunListFeature.State)
    }

    enum Action: Equatable {
        enum View: Equatable {
            case onAppear
            case requestPermissionsButtonTapped
        }

        enum Internal: Equatable {
            case permissionsFetched(TaskResult<AuthorizationRequestStatus>)
            case permissionsRequested(TaskResult<Bool>)
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
    }

    private func view(_ action: Action.View, state _: inout State) -> EffectOf<Self> {
        switch action {
        case .onAppear:
            return .run { send in
                let result = await TaskResult {
                    try await permissions.authorizationRequestStatus()
                }
                await send(._internal(.permissionsFetched(result)))
            }
        case .requestPermissionsButtonTapped:
            return .run { send in
                let result = await TaskResult {
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

struct DebugAppView: View {
    let store: StoreOf<DebugAppFeature>

    var body: some View {
        NavigationStack {
            SwitchStore(store) { state in
                switch state {
                case .initial:
                    ProgressView()
                        .progressViewStyle(.circular)
                        .onAppear { store.send(.view(.onAppear)) }
                case .permissionRequired:
                    Button(
                        "Request Permissions",
                        action: {
                            store.send(.view(.requestPermissionsButtonTapped))
                        }
                    )
                    .buttonStyle(.borderedProminent)
                case .runs:
                    IfLetStore(
                        store.scope(
                            state: /DebugAppFeature.State.runs,
                            action: DebugAppFeature.Action.runs
                        ),
                        then: DebugRunListView.init
                    )
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
