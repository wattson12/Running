import ComposableArchitecture
import Model
import Repository
import SwiftUI

@ViewAction(for: PermissionsFeature.self)
public struct PermissionsView: View {
    public let store: StoreOf<PermissionsFeature>

    public init(store: StoreOf<PermissionsFeature>) {
        self.store = store
    }

    public var body: some View {
        VStack {
            switch store.state.state {
            case .initial:
                Color.clear
                    .onAppear { send(.onAppear) }
            case .requestPermissions:
                RequestPermissionsView(
                    requestPermissionsTapped: {
                        send(.requestPermissionsButtonTapped)
                    }
                )
            case .healthKitNotAvailable:
                HealthKitNotAvailableView()
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
