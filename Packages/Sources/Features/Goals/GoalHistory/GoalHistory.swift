import Foundation
import Model

struct GoalHistory: Equatable, Identifiable {
    let id: Int
    let dateRange: DateRange
    let runs: [Run]
    let distance: Measurement<UnitLength>
    let target: Measurement<UnitLength>?

    init(
        id: Int,
        dateRange: DateRange,
        runs: [Run],
        target: Measurement<UnitLength>?
    ) {
        self.id = id
        self.dateRange = dateRange
        self.runs = runs
        distance = runs.distance
        self.target = target
    }
}
