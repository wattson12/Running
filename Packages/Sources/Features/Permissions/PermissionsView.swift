import ComposableArchitecture
import Model
import Repository
import SwiftUI

public struct PermissionsView: View {
    let store: StoreOf<PermissionsFeature>

    public init(store: StoreOf<PermissionsFeature>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(
            store,
            observe: \.state,
            send: PermissionsFeature.Action.view
        ) { viewStore in
            VStack {
                switch viewStore.state {
                case .initial:
                    Color.clear
                        .onAppear { viewStore.send(.onAppear) }
                case .requestPermissions:
                    RequestPermissionsView(
                        requestPermissionsTapped: {
                            viewStore.send(.requestPermissionsButtonTapped)
                        }
                    )
                case .healthKitNotAvailable:
                    HealthKitNotAvailableView()
                }
            }
        }
    }
}

struct PermissionsView_Previews: PreviewProvider {
    static var previews: some View {
        PermissionsView(
            store: .init(
                initialState: .init(state: .initial),
                reducer: PermissionsFeature.init,
                withDependencies: {
                    $0.repository.permissions._authorizationRequestStatus = { .unknown }
                }
            )
        )
        .previewDisplayName("Unknown")

        PermissionsView(
            store: .init(
                initialState: .init(state: .initial),
                reducer: PermissionsFeature.init,
                withDependencies: {
                    $0.repository.permissions._authorizationRequestStatus = { .shouldRequest }
                }
            )
        )
        .previewDisplayName("Should Request")

        PermissionsView(
            store: .init(
                initialState: .init(state: .initial),
                reducer: PermissionsFeature.init,
                withDependencies: {
                    $0.repository.support._isHealthKitDataAvailable = { false }
                    $0.repository.permissions._authorizationRequestStatus = { .unknown }
                }
            )
        )
        .previewDisplayName("HealthKit Not Available")
    }
}
