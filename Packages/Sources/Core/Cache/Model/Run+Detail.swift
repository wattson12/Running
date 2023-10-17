import Foundation
import SwiftData

@Model
public class RunDetail {
    @Relationship(deleteRule: .cascade)
    public var locations: [Location]
    @Relationship(deleteRule: .cascade)
    public var distanceSamples: [DistanceSample]

    public init(
        locations: [Location],
        distanceSamples: [DistanceSample]
    ) {
        self.locations = locations
        self.distanceSamples = distanceSamples
    }
}
