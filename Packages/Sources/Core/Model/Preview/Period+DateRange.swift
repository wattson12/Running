import Foundation

public extension Goal.Period {
    func startAndEnd(in calendar: Calendar, now: Date) -> (start: Date, end: Date)? {
        let component: Calendar.Component
        switch self {
        case .weekly:
            component = .weekOfYear
        case .monthly:
            component = .month
        case .yearly:
            component = .year
        }

        guard let range = calendar.dateInterval(of: component, for: now) else { return nil }
        return (range.start, range.end)
    }
}
