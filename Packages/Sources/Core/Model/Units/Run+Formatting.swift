import Foundation

public extension Run {
    private func pace(locale: Locale = .current) -> Double {
        let convertedDistance: Double = distance.converted(to: locale.primaryUnit).value

        let minutes = duration.converted(to: .seconds).value
        return minutes / convertedDistance
    }

    func formattedPace(
        locale: Locale = .current
    ) -> String {
        let pace = pace(locale: locale)

        let formatter = DateComponentsFormatter()
        formatter.calendar = locale.calendar
        let formattedPace = formatter.string(from: pace) ?? String(format: "%.2f", pace)

        let measurementFormatter = MeasurementFormatter()
        measurementFormatter.locale = locale
        measurementFormatter.unitStyle = .short
        let symbol = measurementFormatter.string(from: locale.primaryUnit)

        return String(format: "%@ / %@", formattedPace, symbol)
    }
}
