@testable import HealthKitServiceInterface
import XCTest

final class SupportTests: XCTestCase {
    func testIsHealthKitDataAvailablePublicHelper() {
        let isAvailable: Bool = .random()
        let sut: HealthKitSupport = .init(
            isHealthKitDataAvailable: { isAvailable }
        )

        let available = sut.isHealthKitDataAvailable()
        XCTAssertEqual(available, isAvailable)
    }
}
