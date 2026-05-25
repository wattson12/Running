import Foundation
import HealthKit

public protocol StatisticsType: Sendable {
    func sumQuantity() -> HKQuantity?
}

extension HKStatistics: StatisticsType {}

public struct MockStatisticsType: StatisticsType {
    public let quantity: HKQuantity?

    public init(
        quantity: HKQuantity?
    ) {
        self.quantity = quantity
    }

    public func sumQuantity() -> HKQuantity? {
        quantity
    }
}
