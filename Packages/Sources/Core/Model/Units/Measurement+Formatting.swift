import Foundation

public extension Measurement where UnitType == UnitLength {
    func fullValue(locale: Locale = .current) -> String {
        let converted = converted(to: locale.primaryUnit)

        let formatter = MeasurementFormatter()
        formatter.locale = locale
        formatter.unitOptions = [.providedUnit]

        let numberFormatter = NumberFormatter()
        numberFormatter.locale = locale
        numberFormatter.maximumFractionDigits = 2

        formatter.numberFormatter = numberFormatter

        return formatter.string(from: converted)
    }
}

public extension Measurement where UnitType == UnitDuration {
    func fullValue(locale: Locale = .current) -> String {
        let converted = converted(to: .seconds).value

        let formatter = DateComponentsFormatter()
        formatter.calendar = locale.calendar
        formatter.allowedUnits = [.hour, .minute, .second]

        return formatter.string(from: converted) ?? ""
    }

    func summaryValue(locale: Locale = .current) -> String {
        let converted = converted(to: .seconds).value

        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .brief
        formatter.calendar = locale.calendar
        formatter.allowedUnits = [.day, .hour, .minute]

        return formatter.string(from: converted) ?? ""
    }
}
