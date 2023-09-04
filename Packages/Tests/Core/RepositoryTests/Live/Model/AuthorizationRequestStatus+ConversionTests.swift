import HealthKit
import Model
@testable import Repository
import XCTest

final class AuthorizationRequestStatus_ConversionTests: XCTestCase {
    func testAuthorizationRequestStatusConversion() {
        let inputs: [(HKAuthorizationRequestStatus, AuthorizationRequestStatus, UInt)] = [
            (.unknown, .unknown, #line),
            (.shouldRequest, .shouldRequest, #line),
            (.unnecessary, .requested, #line),
        ]

        for (status, expected, line) in inputs {
            let sut = AuthorizationRequestStatus(model: status)
            XCTAssertEqual(sut, expected, line: line)
        }
    }
}
