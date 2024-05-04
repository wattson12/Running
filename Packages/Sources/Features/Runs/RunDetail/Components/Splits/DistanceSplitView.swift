import Charts
import Foundation
import Model
import SwiftUI

struct Split: Identifiable, Equatable {
    let distance: String
    let duration: TimeInterval

    init(distance: String, duration: TimeInterval) {
        self.distance = distance
        self.duration = duration / 60
    }

    var id: String { distance }
}

extension [Split] {
    var domain: [TimeInterval] {
        let durations = map(\.duration)
        var minDuration: TimeInterval = .greatestFiniteMagnitude
        var maxDuration: TimeInterval = .leastNormalMagnitude
        for duration in durations {
            minDuration = Swift.min(minDuration, duration)
            maxDuration = Swift.max(maxDuration, duration)
        }
        return [floor(minDuration - 0.5), ceil(maxDuration + 0.5)]
    }
}

extension TimeInterval {
    var formattedDuration: String {
        let integerDuration = Int(self * 60)

        let seconds = integerDuration % 60
        let minutes = (integerDuration / 60) % 60

        return String(format: "%.0d:%.2d", minutes, seconds)
    }
}

extension [DistanceSample] {
    func splits(locale: Locale) -> [Split] {
        let unit: UnitLength = .primaryUnit(locale: locale)

        let zero: Measurement<UnitLength> = .init(value: 0, unit: unit)
        let splitBoundary: Measurement<UnitLength> = .init(value: 1, unit: unit)

        var distance: Measurement<UnitLength> = zero
        guard let firstDate = first?.startDate else { return [] }
        var splits: [Date] = [firstDate]

        for sample in self {
            distance = distance + sample.distance
            if distance >= splitBoundary {
                distance = distance - splitBoundary
                splits.append(sample.startDate)
            }
        }

        if distance >= splitBoundary, let last {
            distance = zero
            splits.append(last.startDate)
        }

        return zip(splits, splits.dropFirst()).enumerated().map { index, dates in
            let (start, end) = dates
            return Split(
                distance: String(index + 1),
                duration: end.timeIntervalSince(start)
            )
        }
    }
}

struct DistanceSplitView: View {
    let splits: [Split]
    let domain: [TimeInterval]

    var splitSymbol: String {
        UnitLength.primaryUnit(locale: locale).symbol
    }

    @Environment(\.locale) var locale

    init(
        splits: [Split]
    ) {
        self.splits = splits
        domain = splits.domain
    }

    var body: some View {
        Chart {
            ForEach(splits) { sample in
                BarMark(
                    x: .value("Split", sample.distance),
                    y: .value("Duration", sample.duration)
                )
                .cornerRadius(6)
                .foregroundStyle(Color.blue)
            }
        }
        .chartYAxis {
            AxisMarks(values: .automatic) { value in
                if let duration = value.as(Double.self), duration != 0 {
                    AxisValueLabel(duration.formattedDuration)
                }
                AxisGridLine()
                AxisTick()
            }
        }
        .chartXAxis {
            AxisMarks(values: .automatic) { value in
                if let split = value.as(String.self) {
                    AxisValueLabel(split + splitSymbol)
                }
            }
        }
        .chartXVisibleDomain(length: min(splits.count, 7))
        .chartScrollableAxes(.horizontal)
        .chartYScale(domain: domain)
    }
}

struct DistanceSplitView_Previews: PreviewProvider {
    static var previews: some View {
        DistanceSplitView(
            splits: [
                .init(distance: "1", duration: 60 * 5),
                .init(distance: "2", duration: 60 * 4.3),
                .init(distance: "3", duration: 60 * 4.7),
                .init(distance: "4", duration: 60 * 5.1),
                .init(distance: "5", duration: 60 * 7),
            ]
        )
        .frame(height: 250)
        .environment(\.locale, .init(identifier: "en_AU"))
    }
}
