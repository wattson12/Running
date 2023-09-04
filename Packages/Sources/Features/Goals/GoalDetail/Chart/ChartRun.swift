import Foundation
import Model

struct ChartRun: Equatable, Identifiable {
    let id: UUID = .init()
    let run: Run
    let start: Measurement<UnitLength>
    let end: Measurement<UnitLength>
}

extension [ChartRun] {
    init(runs: [Run]) {
        var currentStart: Measurement<UnitLength> = .init(value: 0, unit: .kilometers)
        var values: [ChartRun] = []
        for run in runs {
            values.append(
                .init(
                    run: run,
                    start: currentStart,
                    end: currentStart + run.distance
                )
            )
            currentStart = currentStart + run.distance
        }
        self = values
    }
}
