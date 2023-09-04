import Foundation
import HealthKit
import HealthKitServiceInterface

extension HealthKitPermissions {
    static func live(
        store: HealthStoreType = HKHealthStore.shared
    ) -> Self {
        .init(
            authorizationRequestStatus: {
                try await Implementation.authorizationRequestStatus(in: store)
            },
            requestAuthorization: {
                try await Implementation.requestAuthorization(in: store)
            }
        )
    }

    private enum Implementation {
        static func authorizationRequestStatus(
            in store: HealthStoreType
        ) async throws -> HKAuthorizationRequestStatus {
            try await store.statusForAuthorizationRequest(
                toShare: .sharePermissions,
                read: .readPermissions
            )
        }

        static func requestAuthorization(
            in store: HealthStoreType
        ) async throws {
            try await store.requestAuthorization(
                toShare: .sharePermissions,
                read: .readPermissions
            )
        }
    }
}
