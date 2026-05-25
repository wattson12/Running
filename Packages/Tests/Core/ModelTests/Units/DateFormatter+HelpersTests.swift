@testable import Model
import Testing
import Foundation

@Suite
struct DateFormatter_HelpersTests {
    @Test func runDateFormatterIsCorrect() {
        let sut: DateFormatter = .run
        sut.locale = .init(identifier: "en_GB")

        let date = Date(timeIntervalSince1970: 1_000_000)

        #expect(sut.string(from: date) == "12 Jan")
    }

    @Test func rangeTitleIsCorrectForWeeklyPeriod() {
        let sut: DateFormatter = .rangeTitle(for: .weekly)
        sut.locale = .init(identifier: "en_GB")

        let date = Date(timeIntervalSince1970: 1_000_000)

        #expect(sut.string(from: date) == "12 Jan")
    }

    @Test func rangeTitleIsCorrectForMonthlyPeriod() {
        let sut: DateFormatter = .rangeTitle(for: .monthly)
        sut.locale = .init(identifier: "en_GB")

        let date = Date(timeIntervalSince1970: 1_000_000)

        #expect(sut.string(from: date) == "Jan '70")
    }

    @Test func rangeTitleIsCorrectForYearlyPeriod() {
        let sut: DateFormatter = .rangeTitle(for: .yearly)
        sut.locale = .init(identifier: "en_GB")

        let date = Date(timeIntervalSince1970: 1_000_000)

        #expect(sut.string(from: date) == "1970")
    }

    @Test func sectionMonthIsCorrect() {
        let sut: DateFormatter = .sectionMonth
        sut.locale = .init(identifier: "en_GB")

        let date = Date(timeIntervalSince1970: 1_000_000)

        #expect(sut.string(from: date) == "January 70")
    }
}
