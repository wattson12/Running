import HealthKit
@testable import HealthKitServiceLive
import XCTest

final class HKObjectType_ReadPermissions: XCTestCase {
    func testReadPermissionsAreCorrect() {
        let expectedPermissions: Set<HKObjectType> = [
            .workoutType(),
            HKSeriesType.activitySummaryType(),
            HKSeriesType.workoutRoute(),
            HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
        ]

        XCTAssertEqual(Set<HKObjectType>.readPermissions, expectedPermissions)
    }
}
