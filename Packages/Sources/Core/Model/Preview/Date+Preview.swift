import Foundation

public extension Date {
    static var preview: Date = .mock(date: "221231")
}

extension Date {
    static func mock(date: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYMMdd"
        return formatter.date(from: date)!
    }
}
