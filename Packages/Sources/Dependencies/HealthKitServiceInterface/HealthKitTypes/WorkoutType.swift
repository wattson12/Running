import Foundation
import HealthKit

public protocol WorkoutType {
    var uuid: UUID { get }
    var startDate: Date { get }
    var duration: TimeInterval { get }
    func stats(for quantityType: HKQuantityType) -> StatisticsType?
}

extension HKWorkout: WorkoutType {
    public func stats(for quantityType: HKQuantityType) -> StatisticsType? {
        statistics(for: quantityType)
    }
}

public struct MockWorkoutType: WorkoutType, Equatable {
    public var uuid: UUID
    public var startDate: Date
    public var duration: TimeInterval
    public var allStatistics: [HKQuantityType: StatisticsType]

    public init(
        uuid: UUID,
        startDate: Date,
        duration: TimeInterval,
        allStatistics: [HKQuantityType: StatisticsType]
    ) {
        self.uuid = uuid
        self.startDate = startDate
        self.duration = duration
        self.allStatistics = allStatistics
    }

    public init(
        uuid: UUID = .init(),
        duration: TimeInterval,
        distance: Double
    ) {
        self.uuid = uuid
        startDate = .now
        self.duration = duration * 60
        allStatistics = [
            .init(.distanceWalkingRunning): MockStatisticsType(quantity: .init(unit: .meter(), doubleValue: distance * 1000)),
        ]
    }

    public func stats(for quantityType: HKQuantityType) -> StatisticsType? {
        allStatistics[quantityType]
    }

    public static func == (lhs: MockWorkoutType, rhs: MockWorkoutType) -> Bool {
        (lhs.uuid, lhs.duration, lhs.startDate) == (rhs.uuid, rhs.duration, rhs.startDate)
    }
}
