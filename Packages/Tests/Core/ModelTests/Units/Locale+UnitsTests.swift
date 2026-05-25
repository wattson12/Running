@testable import Model
import Testing
import Foundation

@Suite
struct Locale_UnitsTests {
    @Test func primaryUnitIsCorrectForLocalesWithMetricMeasurementSystem() {
        let locale = Locale(identifier: "en_AU")
        #expect(locale.measurementSystem == .metric)

        #expect(locale.primaryUnit == .kilometers)
    }

    @Test func primaryUnitIsCorrectForLocalesWithUKMeasurementSystem() {
        let locale = Locale(identifier: "en_GB")
        #expect(locale.measurementSystem == .uk)

        #expect(locale.primaryUnit == .miles)
    }

    @Test func primaryUnitIsCorrectForLocalesWithUSMeasurementSystem() {
        let locale = Locale(identifier: "en_US")
        #expect(locale.measurementSystem == .us)

        #expect(locale.primaryUnit == .miles)
    }

    @Test func secondaryUnitIsCorrectForLocalesWithMetricMeasurementSystem() {
        let locale = Locale(identifier: "en_AU")
        #expect(locale.measurementSystem == .metric)

        #expect(locale.secondaryUnit == .meters)
    }

    @Test func secondaryUnitIsCorrectForLocalesWithUKMeasurementSystem() {
        let locale = Locale(identifier: "en_GB")
        #expect(locale.measurementSystem == .uk)

        #expect(locale.secondaryUnit == .feet)
    }

    @Test func secondaryUnitIsCorrectForLocalesWithUSMeasurementSystem() {
        let locale = Locale(identifier: "en_US")
        #expect(locale.measurementSystem == .us)

        #expect(locale.secondaryUnit == .feet)
    }

    @Test func unitLengthPrimaryUnitHelperIsCorrect() {
        let inputs: [(Locale, UnitLength, SourceLocation)] = [
            (.init(identifier: "en_AU"), .kilometers, #_sourceLocation),
            (.init(identifier: "en_GB"), .miles, #_sourceLocation),
            (.init(identifier: "en_US"), .miles, #_sourceLocation),
        ]

        for (locale, expected, sourceLocation) in inputs {
            let sut: UnitLength = .primaryUnit(locale: locale)
            #expect(sut == expected, sourceLocation: sourceLocation)
        }
    }

    @Test func unitLengthSecondaryUnitHelperIsCorrect() {
        let inputs: [(Locale, UnitLength, SourceLocation)] = [
            (.init(identifier: "en_AU"), .meters, #_sourceLocation),
            (.init(identifier: "en_GB"), .feet, #_sourceLocation),
            (.init(identifier: "en_US"), .feet, #_sourceLocation),
        ]

        for (locale, expected, sourceLocation) in inputs {
            let sut: UnitLength = .secondaryUnit(locale: locale)
            #expect(sut == expected, sourceLocation: sourceLocation)
        }
    }
}
