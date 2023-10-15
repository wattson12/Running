import Foundation

public extension Run {
    struct Detail: Equatable, Hashable {
        public var locations: [Location]
        public var distanceSamples: [DistanceSample]

        public init(
            locations: [Location],
            distanceSamples: [DistanceSample]
        ) {
            self.locations = locations
            self.distanceSamples = distanceSamples
        }
    }
}
