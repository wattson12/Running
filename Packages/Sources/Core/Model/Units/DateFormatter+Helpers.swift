import Foundation

public extension RelativeDateTimeFormatter {
    static var run: RelativeDateTimeFormatter {
        let formatter = RelativeDateTimeFormatter()
        formatter.formattingContext = .listItem
        return formatter
    }
}

public extension DateFormatter {
    static var run: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM"
        return formatter
    }

    static func rangeTitle(for period: Goal.Period) -> DateFormatter {
        let dateFormatter = DateFormatter()

        switch period {
        case .weekly:
            dateFormatter.dateFormat = "d MMM"
        case .monthly:
            dateFormatter.dateFormat = "MMM ''yy"
        case .yearly:
            dateFormatter.dateFormat = "yyyy"
        }

        return dateFormatter
    }

    static var sectionMonth: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM YY"
        return formatter
    }
}
