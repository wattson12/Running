import Model
import SwiftUI

extension DateRange {
    var dateForHistory: Date {
        switch period {
        case .weekly:
            return start
        case .monthly, .yearly:
            let interval = end.timeIntervalSince(start)
            return start.addingTimeInterval(interval / 2)
        }
    }
}

public extension DateFormatter {
    static var weekHistorySubtitle: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "''yy"
        return formatter
    }
}

struct GoalHistoryRow: View {
    let history: GoalHistory

    @Environment(\.locale) var locale

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(history.dateRange.dateForHistory, formatter: DateFormatter.rangeTitle(for: history.dateRange.period))
                    .font(.title)

                if history.dateRange.period == .weekly {
                    Text(history.dateRange.dateForHistory, formatter: DateFormatter.weekHistorySubtitle)
                        .font(.body)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            VStack(alignment: .trailing) {
                Text(history.distance.fullValue(locale: locale))
                if let target = history.target {
                    Group {
                        Text("of ") + Text(target.fullValue(locale: locale))
                    }
                    .foregroundStyle(.secondary)
                }
            }
            .font(.body)
        }
    }
}

#Preview("Weekly") {
    GoalHistoryRow(
        history: .init(
            id: 1,
            dateRange: .mock(
                period: .weekly,
                start: Date(),
                end: Date()
            ),
            runs: [.mock(offset: 0, distance: 100)],
            target: nil
        )
    )
    .environment(\.locale, .init(identifier: "en_AU"))
}

#Preview("Monthly") {
    GoalHistoryRow(
        history: .init(
            id: 1,
            dateRange: .mock(
                period: .monthly,
                start: Date(),
                end: Date()
            ),
            runs: [.mock(offset: 0, distance: 100)],
            target: nil
        )
    )
    .environment(\.locale, .init(identifier: "en_AU"))
}

#Preview("Yearly") {
    GoalHistoryRow(
        history: .init(
            id: 1,
            dateRange: .mock(
                period: .yearly,
                start: Date(),
                end: Date()
            ),
            runs: [.mock(offset: 0, distance: 100)],
            target: nil
        )
    )
    .environment(\.locale, .init(identifier: "en_AU"))
}

#Preview("Yearly with target") {
    GoalHistoryRow(
        history: .init(
            id: 1,
            dateRange: .mock(
                period: .yearly,
                start: Date(),
                end: Date()
            ),
            runs: [.mock(offset: 0, distance: 100)],
            target: .init(value: 200, unit: .kilometers)
        )
    )
    .environment(\.locale, .init(identifier: "en_AU"))
}
