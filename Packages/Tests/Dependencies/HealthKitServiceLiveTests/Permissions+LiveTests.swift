import HealthKit
import HealthKitServiceInterface
@testable import HealthKitServiceLive
import Testing
import Foundation

@Suite
struct Permissions_LiveTests {
    @Test func authorizationRequestStatus() async throws {
        let possibleStatus: [HKAuthorizationRequestStatus] = [
            .shouldRequest,
            .unknown,
            .unnecessary,
        ]

        let expectedStatus: HKAuthorizationRequestStatus = try #require(possibleStatus.randomElement())

        let store = MockHealthStoreType(
            _statusForAuthorizationRequest: { share, read in
                #expect(share == .sharePermissions)
                #expect(read == .readPermissions)
                return expectedStatus
            }
        )

        let sut: HealthKitPermissions = .live(store: store)

        let status = try await sut.authorizationRequestStatus()
        #expect(status == expectedStatus)
    }

    @Test func requestAuthorization() async throws {
        try await confirmation { expectation in
            let store = MockHealthStoreType(
                _requestAuthorization: { share, read in
                    #expect(share == .sharePermissions)
                    #expect(read == .readPermissions)
                    expectation()
                }
            )
            
            let sut: HealthKitPermissions = .live(store: store)
            
            try await sut.requestAuthorization()
        }
    }
}
