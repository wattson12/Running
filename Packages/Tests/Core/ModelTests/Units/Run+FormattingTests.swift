@testable import Model
import XCTest

final class Run_FormattingTests: XCTestCase {
    func testFormattedPaceIsCorrectForMetricLocale() {
        let run: Run = .mock(
            distance: .init(value: 5.67, unit: .kilometers),
            duration: .init(value: 27.89, unit: .minutes)
        )

        let locale: Locale = .init(identifier: "en_AU")

        let sut = run.formattedPace(locale: locale)
        XCTAssertEqual(sut, "4:55 / km")
    }

    func testFormattedPaceIsCorrectForNonMetricLocale() {
        let run: Run = .mock(
            distance: .init(value: 5.67, unit: .miles),
            duration: .init(value: 27.89, unit: .minutes)
        )

        let locale: Locale = .init(identifier: "en_GB")

        let sut = run.formattedPace(locale: locale)
        XCTAssertEqual(sut, "4:55 / mi")
    }
}
