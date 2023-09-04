@testable import Model
import XCTest

final class DateFormatter_HelpersTests: XCTestCase {
    func testRunDateFormatterIsCorrect() {
        let sut: DateFormatter = .run
        sut.locale = .init(identifier: "en_GB")

        let date = Date(timeIntervalSince1970: 1_000_000)

        XCTAssertEqual(sut.string(from: date), "12 Jan")
    }

    func testRangeTitleIsCorrectForWeeklyPeriod() {
        let sut: DateFormatter = .rangeTitle(for: .weekly)
        sut.locale = .init(identifier: "en_GB")

        let date = Date(timeIntervalSince1970: 1_000_000)

        XCTAssertEqual(sut.string(from: date), "12 Jan")
    }

    func testRangeTitleIsCorrectForMonthlyPeriod() {
        let sut: DateFormatter = .rangeTitle(for: .monthly)
        sut.locale = .init(identifier: "en_GB")

        let date = Date(timeIntervalSince1970: 1_000_000)

        XCTAssertEqual(sut.string(from: date), "Jan '70")
    }

    func testRangeTitleIsCorrectForYearlyPeriod() {
        let sut: DateFormatter = .rangeTitle(for: .yearly)
        sut.locale = .init(identifier: "en_GB")

        let date = Date(timeIntervalSince1970: 1_000_000)

        XCTAssertEqual(sut.string(from: date), "1970")
    }

    func testSectionMonthIsCorrect() {
        let sut: DateFormatter = .sectionMonth
        sut.locale = .init(identifier: "en_GB")

        let date = Date(timeIntervalSince1970: 1_000_000)

        XCTAssertEqual(sut.string(from: date), "January 70")
    }
}
