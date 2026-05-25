import Dependencies
import HealthKitServiceInterface
@testable import Repository
import Testing
import Foundation

@Suite
struct Support_Live {
    @Test func isHealthKitDataAvailableUsesCorrectFunctionFromHealthKitService() async throws {
        let available: Bool = .random()
        let sut: Support = withDependencies {
            $0.healthKit.support._isHealthKitDataAvailable = { available }
        } operation: {
            .live()
        }

        let isAvailable = sut.isHealthKitDataAvailable()
        #expect(isAvailable == available)
    }
}
