import Dependencies
import Foundation
import HealthKitServiceInterface

extension Support {
    static func live() -> Self {
        @Dependency(\.healthKit.support) var healthKitSupport

        return .init(
            isHealthKitDataAvailable: {
                healthKitSupport.isHealthKitDataAvailable()
            }
        )
    }
}
