import HealthKit
import HealthKitServiceInterface
@testable import HealthKitServiceLive
import XCTest
import XCTestDynamicOverlay

final class Support_LiveTests: XCTestCase {
    override func tearDown() {
        super.tearDown()

        MockHealthStoreType._isHealthDataAvailable = unimplemented()
    }

    func testIsHealthDataAvailable() {
        let isAvailable: Bool = .random()

        let sut: HealthKitSupport = .live(storeType: MockHealthStoreType.self)

        MockHealthStoreType._isHealthDataAvailable = { isAvailable }

        XCTAssertEqual(sut.isHealthKitDataAvailable(), isAvailable)
    }
}
