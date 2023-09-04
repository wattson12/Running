import Dependencies
import HealthKitServiceInterface
@testable import Repository
import XCTest

final class Support_Live: XCTestCase {
    func testIsHealthKitDataAvailableUsesCorrectFunctionFromHealthKitService() async throws {
        let available: Bool = .random()
        let sut: Support = withDependencies {
            $0.healthKit.support._isHealthKitDataAvailable = { available }
        } operation: {
            .live()
        }

        let isAvailable = sut.isHealthKitDataAvailable()
        XCTAssertEqual(isAvailable, available)
    }
}
