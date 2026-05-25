import HealthKit
@testable import HealthKitServiceLive
import Testing
import Foundation

@Suite
struct HKObjectType_ReadPermissions {
    @Test func readPermissionsAreCorrect() {
        let expectedPermissions: Set<HKObjectType> = [
            .workoutType(),
            HKSeriesType.activitySummaryType(),
            HKSeriesType.workoutRoute(),
            HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
        ]

        #expect(Set<HKObjectType>.readPermissions == expectedPermissions)
    }
}
