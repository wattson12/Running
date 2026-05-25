import HealthKit
import Model
@testable import Repository
import Testing
import Foundation

@Suite
struct AuthorizationRequestStatus_ConversionTests {
    @Test func authorizationRequestStatusConversion() {
        let inputs: [(HKAuthorizationRequestStatus, AuthorizationRequestStatus, SourceLocation)] = [
            (.unknown, .unknown, #_sourceLocation),
            (.shouldRequest, .shouldRequest, #_sourceLocation),
            (.unnecessary, .requested, #_sourceLocation),
        ]

        for (status, expected, sourceLocation) in inputs {
            let sut = AuthorizationRequestStatus(model: status)
            #expect(sut == expected, sourceLocation: sourceLocation)
        }
    }
}
