import HealthKit
import HealthKitServiceInterface
@testable import HealthKitServiceLive
import XCTest
import XCTestDynamicOverlay

final class Support_LiveTests: XCTestCase {
    override func tearDown() {
        super.tearDown()

        MockHealthStoreType._isHealthDataAvailable.setValue(unimplemented(placeholder: false))
    }

    func testIsHealthDataAvailable() {
        let isAvailable: Bool = .random()

        let sut: HealthKitSupport = .live(storeType: MockHealthStoreType.self)

        MockHealthStoreType._isHealthDataAvailable.setValue({ isAvailable })

        XCTAssertEqual(sut.isHealthKitDataAvailable(), isAvailable)
    }
}
