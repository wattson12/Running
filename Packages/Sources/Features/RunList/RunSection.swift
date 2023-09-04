import Foundation
import IdentifiedCollections
import Model

public struct RunSection: Equatable, Identifiable {
    public let id: UUID
    let title: String
    let runs: IdentifiedArrayOf<Run>
    let additionalDistance: Measurement<UnitLength>?

    public init(
        id: UUID,
        title: String,
        runs: IdentifiedArrayOf<Run>,
        additionalDistance: Measurement<UnitLength>? = nil
    ) {
        self.id = id
        self.title = title
        self.runs = runs
        self.additionalDistance = additionalDistance
    }

    var distance: Measurement<UnitLength> {
        let distanceFromRuns = runs.distance

        if let additionalDistance {
            return distanceFromRuns + additionalDistance
        } else {
            return distanceFromRuns
        }
    }
}
