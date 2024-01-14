import Charts
import Foundation
import Model
import SwiftUI

struct Split: Identifiable, Equatable {
    let distance: String
    let duration: TimeInterval

    var id: String { distance }
}

extension TimeInterval {
    var formattedDuration: String {
        let integerDuration = Int(self)

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

    var splitSymbol: String {
        UnitLength.primaryUnit(locale: locale).symbol
    }

    @Environment(\.locale) var locale

    init(
        splits: [Split]
    ) {
        self.splits = splits
    }

    var body: some View {
        GeometryReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                Chart(splits) { sample in
                    BarMark(
                        x: .value("Split", sample.distance),
                        y: .value("Duration", sample.duration)
                    )
                    .cornerRadius(6)
                    .foregroundStyle(Color.blue)
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
                .frame(width: max(50 * CGFloat(splits.count), proxy.size.width))
            }
        }
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
