import ComposableArchitecture
import Model
@testable import Permissions
import Testing
import Foundation

@MainActor
@Suite
struct PermissionsFeatureTests {
    @Test func flowWithPermissionsAlreadyAccepted() async throws {
        let store = TestStore(
            initialState: .init(state: .initial),
            reducer: PermissionsFeature.init,
            withDependencies: {
                $0.repository.support._isHealthKitDataAvailable = { true }
                $0.repository.permissions._requestAuthorization = {}
                $0.repository.permissions._authorizationRequestStatus = { .requested }
            }
        )

        await store.send(.view(.onAppear))

        await store.receive(\._internal.authorizationRequestStatusCompleted.success, .requested)
        
        await store.receive(\.delegate.permissionsAvailable)
    }

    @Test func permissionRequestHappyPath() async throws {
        let store = TestStore(
            initialState: .init(state: .initial),
            reducer: PermissionsFeature.init,
            withDependencies: {
                $0.repository.support._isHealthKitDataAvailable = { true }
                $0.repository.permissions._requestAuthorization = {}

                let firstStatusCall: LockIsolated<Bool> = .init(true)
                $0.repository.permissions._authorizationRequestStatus = {
                    let isFirstCall = firstStatusCall.value
                    firstStatusCall.setValue(false)
                    if isFirstCall {
                        return .shouldRequest
                    } else {
                        return .requested
                    }
                }
            }
        )

        // setup state on appearance
        await store.send(.view(.onAppear))

        await store.receive(\._internal.authorizationRequestStatusCompleted.success, .shouldRequest) {
            $0.state = .requestPermissions
        }

        // user taps request
        await store.send(.view(.requestPermissionsButtonTapped))

        await store.receive(\._internal.requestPermissionsCompleted.success)

        await store.receive(\._internal.authorizationRequestStatusCompleted.success, .requested)

        await store.receive(\.delegate.permissionsAvailable)
    }

    @Test func flowWithHealthKitUnavailable() async throws {
        let store = TestStore(
            initialState: .init(state: .initial),
            reducer: PermissionsFeature.init,
            withDependencies: {
                $0.repository.support._isHealthKitDataAvailable = { false }
            }
        )

        await store.send(.view(.onAppear)) {
            $0.state = .healthKitNotAvailable
        }
    }
}
