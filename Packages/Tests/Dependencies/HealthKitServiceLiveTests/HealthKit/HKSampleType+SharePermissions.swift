import HealthKit
@testable import HealthKitServiceLive
import Testing
import Foundation

struct HKSampleType_SharePermissions {
    @Test func sharePermissionsAreCorrect() {
        #expect(Set<HKSampleType>.sharePermissions == [])
    }
}
