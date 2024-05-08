import Foundation

public struct DistanceSample: Equatable, Hashable, Codable {
    public let startDate: Date
    public let distance: Measurement<UnitLength>

    public init(
        startDate: Date,
        distance: Measurement<UnitLength>
    ) {
        self.startDate = startDate
        self.distance = distance
    }
}
