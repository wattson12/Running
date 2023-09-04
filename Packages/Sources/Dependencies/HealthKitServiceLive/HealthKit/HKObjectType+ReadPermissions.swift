import Foundation
import HealthKit

extension Set<HKObjectType> {
    static let readPermissions: Self = [
        .workoutType(),
        HKSeriesType.activitySummaryType(),
        HKSeriesType.workoutRoute(),
        HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
    ]
}
