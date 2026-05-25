@testable import Model
import Testing
import Foundation

@MainActor
struct Measurement_FormattingTests {
    @Test func unitLengthFullValueFormatting() {
        let locale: Locale = .init(identifier: "en_AU")
        let distance = 123.40
        let measurement: Measurement<UnitLength> = .init(value: distance, unit: .kilometers)

        let sut = measurement.fullValue(locale: locale)
        #expect(sut == "123.40 km")
    }

    @Test func unitDurationFullValueFormatting() {
        let locale: Locale = .init(identifier: "en_AU")
        let duration = 567.89
        let measurement: Measurement<UnitDuration> = .init(value: duration, unit: .seconds)

        let sut = measurement.fullValue(locale: locale)
        #expect(sut == "9:27")
    }
}
