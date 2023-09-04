@testable import Model
import XCTest

final class Locale_UnitsTests: XCTestCase {
    func testPrimaryUnitIsCorrectForLocalesWithMetricMeasurementSystem() {
        let locale = Locale(identifier: "en_AU")
        XCTAssertEqual(locale.measurementSystem, .metric)

        XCTAssertEqual(locale.primaryUnit, .kilometers)
    }

    func testPrimaryUnitIsCorrectForLocalesWithUKMeasurementSystem() {
        let locale = Locale(identifier: "en_GB")
        XCTAssertEqual(locale.measurementSystem, .uk)

        XCTAssertEqual(locale.primaryUnit, .miles)
    }

    func testPrimaryUnitIsCorrectForLocalesWithUSMeasurementSystem() {
        let locale = Locale(identifier: "en_US")
        XCTAssertEqual(locale.measurementSystem, .us)

        XCTAssertEqual(locale.primaryUnit, .miles)
    }

    func testSecondaryUnitIsCorrectForLocalesWithMetricMeasurementSystem() {
        let locale = Locale(identifier: "en_AU")
        XCTAssertEqual(locale.measurementSystem, .metric)

        XCTAssertEqual(locale.secondaryUnit, .meters)
    }

    func testSecondaryUnitIsCorrectForLocalesWithUKMeasurementSystem() {
        let locale = Locale(identifier: "en_GB")
        XCTAssertEqual(locale.measurementSystem, .uk)

        XCTAssertEqual(locale.secondaryUnit, .feet)
    }

    func testSecondaryUnitIsCorrectForLocalesWithUSMeasurementSystem() {
        let locale = Locale(identifier: "en_US")
        XCTAssertEqual(locale.measurementSystem, .us)

        XCTAssertEqual(locale.secondaryUnit, .feet)
    }

    func testUnitLengthPrimaryUnitHelperIsCorrect() {
        let inputs: [(Locale, UnitLength, UInt)] = [
            (.init(identifier: "en_AU"), .kilometers, #line),
            (.init(identifier: "en_GB"), .miles, #line),
            (.init(identifier: "en_US"), .miles, #line),
        ]

        for (locale, expected, line) in inputs {
            let sut: UnitLength = .primaryUnit(locale: locale)
            XCTAssertEqual(sut, expected, line: line)
        }
    }

    func testUnitLengthSecondaryUnitHelperIsCorrect() {
        let inputs: [(Locale, UnitLength, UInt)] = [
            (.init(identifier: "en_AU"), .meters, #line),
            (.init(identifier: "en_GB"), .feet, #line),
            (.init(identifier: "en_US"), .feet, #line),
        ]

        for (locale, expected, line) in inputs {
            let sut: UnitLength = .secondaryUnit(locale: locale)
            XCTAssertEqual(sut, expected, line: line)
        }
    }
}
