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

public extension Run.Detail {
    static func mock(
        locations: [Location] = [],
        distanceSamples: [DistanceSample] = .preview
    ) -> Run.Detail {
        .init(
            locations: locations,
            distanceSamples: distanceSamples
        )
    }
}
