import Foundation
import SwiftData

@Model
public class Run {
    public let id: UUID
    public var startDate: Date
    public var distance: Double
    public var duration: Double
    public var locations: [Location]
    public var distanceSamples: [DistanceSample]

    public init(
        id: UUID,
        startDate: Date,
        distance: Double,
        duration: Double,
        locations: [Location],
        distanceSamples: [DistanceSample]
    ) {
        self.id = id
        self.startDate = startDate
        self.distance = distance
        self.duration = duration
        self.locations = locations
        self.distanceSamples = distanceSamples
    }
}
