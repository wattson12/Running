import Foundation

public extension Collection<Run> {
    var distance: Measurement<UnitLength> {
        map(\.distance)
            .reduce(.init(value: 0, unit: .kilometers), +)
    }
}
