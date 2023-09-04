@testable import Model
import XCTest

final class Measurement_FormattingTests: XCTestCase {
    func testUnitLengthFullValueFormatting() {
        let locale: Locale = .init(identifier: "en_AU")
        let distance = 123.40
        let measurement: Measurement<UnitLength> = .init(value: distance, unit: .kilometers)

        let sut = measurement.fullValue(locale: locale)
        XCTAssertEqual(sut, "123.4 km")
    }

    func testUnitDurationFullValueFormatting() {
        let locale: Locale = .init(identifier: "en_AU")
        let duration = 567.89
        let measurement: Measurement<UnitDuration> = .init(value: duration, unit: .seconds)

        let sut = measurement.fullValue(locale: locale)
        XCTAssertEqual(sut, "9:27")
    }
}
