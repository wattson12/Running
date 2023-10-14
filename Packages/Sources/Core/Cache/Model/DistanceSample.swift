import Foundation
import SwiftData

@Model
public class DistanceSample {
    public let startDate: Date
    public let distance: Double

    public init(
        startDate: Date,
        distance: Double
    ) {
        self.startDate = startDate
        self.distance = distance
    }
}
