import Charts
import Model
import SwiftUI

struct AltitudeChartView: View {
    let locations: [Location]
    let splitTimes: [Date]
    @Environment(\.locale) var locale

    var altitudeSymbol: String {
        UnitLength.secondaryUnit(locale: locale).symbol
    }

    var splitSymbol: String {
        UnitLength.primaryUnit(locale: locale).symbol
    }

    init(
        locations: [Location],
        splits: [Split]
    ) {
        let sortedLocations = locations
            .sorted(by: { $0.timestamp < $1.timestamp })

        self.locations = sortedLocations
        guard let startTime = sortedLocations.first?.timestamp else {
            self.splitTimes = []
            return
        }

        var splitTimes: [Date] = []
        var runningTime: TimeInterval = 0
        for split in splits {
            runningTime += split.duration
            splitTimes.append(startTime.addingTimeInterval(runningTime))
        }
        self.splitTimes = splitTimes
    }

    var body: some View {
        Chart {
            ForEach(locations) { location in
                LineMark(
                    x: .value("Timestamp", location.timestamp),
                    y: .value("Altitude", location.altitude.converted(to: .secondaryUnit(locale: locale)).value)
                )
                .interpolationMethod(.cardinal)
                .foregroundStyle(Color.blue)
            }
        }
        .chartXAxis {
            AxisMarks(values: splitTimes) { value in
                AxisValueLabel(labelForXAxis(value: value))
                AxisGridLine()
            }
        }
        .chartYAxis {
            AxisMarks(values: .automatic) { value in
                if let label = labelForYAxis(value: value) {
                    AxisValueLabel(label)
                    AxisGridLine()
                }
            }
        }
    }

    private func labelForXAxis(value: AxisValue) -> String {
        "\(value.index + 1)" + splitSymbol
    }

    private func labelForYAxis(value: AxisValue) -> String? {
        guard let value = value.as(Double.self) else { return nil }
        return String(format: "%.0f%@", value, altitudeSymbol)
    }
}

#Preview {
    let run: Run = .mock(
        distance: .init(value: 5, unit: .kilometers),
        duration: .init(value: 30, unit: .minutes),
        detail: .mock(
            locations: .loop,
            distanceSamples: .preview
        )
    )
    return AltitudeChartView(
        locations: run.detail?.locations ?? [],
        splits: run.detail?.distanceSamples.splits(locale: .init(identifier: "en_AU")) ?? []
    )
}
