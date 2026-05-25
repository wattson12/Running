@testable import HealthKitServiceInterface
import Testing
import Foundation

struct SupportTests {
    @Test func isHealthKitDataAvailablePublicHelper() {
        let isAvailable: Bool = .random()
        let sut: HealthKitSupport = .init(
            isHealthKitDataAvailable: { isAvailable }
        )

        let available = sut.isHealthKitDataAvailable()
        #expect(available == isAvailable)
    }
}
