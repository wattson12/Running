import HealthKit
@testable import HealthKitServiceLive
import XCTest

final class HKSampleType_SharePermissions: XCTestCase {
    func testSharePermissionsAreCorrect() {
        XCTAssertEqual(Set<HKSampleType>.sharePermissions, [])
    }
}
