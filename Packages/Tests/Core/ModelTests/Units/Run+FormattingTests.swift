@testable import Model
import Testing
import Foundation

@Suite
struct Run_FormattingTests {
    @Test func formattedPaceIsCorrectForMetricLocale() {
        let run: Run = .mock(
            distance: .init(value: 5.67, unit: .kilometers),
            duration: .init(value: 27.89, unit: .minutes)
        )

        let locale: Locale = .init(identifier: "en_AU")

        let sut = run.formattedPace(locale: locale)
        #expect(sut == "4:55 / km")
    }

    @Test func formattedPaceIsCorrectForNonMetricLocale() {
        let run: Run = .mock(
            distance: .init(value: 5.67, unit: .miles),
            duration: .init(value: 27.89, unit: .minutes)
        )

        let locale: Locale = .init(identifier: "en_GB")

        let sut = run.formattedPace(locale: locale)
        #expect(sut == "4:55 / mi")
    }
}
