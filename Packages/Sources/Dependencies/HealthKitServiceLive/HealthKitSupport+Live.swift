import Foundation
import HealthKit
import HealthKitServiceInterface

extension HealthKitSupport {
    static func live(
        storeType: HealthStoreType.Type = HKHealthStore.self
    ) -> Self {
        .init(
            isHealthKitDataAvailable: {
                storeType.isHealthDataAvailable()
            }
        )
    }
}
