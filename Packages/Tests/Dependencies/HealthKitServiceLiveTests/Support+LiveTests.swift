import HealthKit
import HealthKitServiceInterface
@testable import HealthKitServiceLive
import Testing
import Foundation
import XCTestDynamicOverlay

@Suite
final class Support_LiveTests {
    
    deinit {
        MockHealthStoreType._isHealthDataAvailable.setValue(unimplemented(placeholder: false))
    }

    @Test func isHealthDataAvailable() {
        let isAvailable: Bool = .random()

        let sut: HealthKitSupport = .live(storeType: MockHealthStoreType.self)

        MockHealthStoreType._isHealthDataAvailable.setValue({ isAvailable })

        #expect(sut.isHealthKitDataAvailable() == isAvailable)
    }
}
