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
    func splits(isMetric _: Bool) -> [Split] {
        let unit: UnitLength = .primaryUnit()

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
    let isMetric: Bool

    var splitSymbol: String {
        UnitLength.primaryUnit().symbol
    }

    init(
        distances: [DistanceSample],
        isMetric: Bool
    ) {
        splits = distances.splits(isMetric: isMetric)
        self.isMetric = isMetric
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
            distances: [],
//            distances: .preview(
//                predicate: { run in
//                    run.distance > .init(value: 5, unit: .kilometers) && run.distance < .init(value: 6, unit: .kilometers)
//                }
//            ),
            isMetric: true
        )
        .frame(height: 250)
        .previewDisplayName("5k")

//        DistanceSplitView(
//            distances: .preview(
//                predicate: { run in
//                    run.distance > .init(value: 5, unit: .miles) && run.distance < .init(value: 6, unit: .miles)
//                }
//            ),
//            isMetric: false
//        )
//        .frame(height: 250)
//        .previewDisplayName("5mi")
//
//        DistanceSplitView(
//            distances: .preview(
//                predicate: { run in
//                    run.distance > .init(value: 10, unit: .kilometers) && run.distance < .init(value: 11, unit: .kilometers)
//                }
//            ),
//            isMetric: true
//        )
//        .frame(height: 250)
//        .previewDisplayName("Long Run")
//
//        DistanceSplitView(
//            distances: .preview(
//                predicate: { run in
//                    run.distance > .init(value: 20, unit: .kilometers)
//                }
//            ),
//            isMetric: true
//        )
//        .frame(height: 250)
//        .previewDisplayName("Half Marathon")
    }
}
