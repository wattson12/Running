@testable import Model
import Resources
import SwiftUI
import Testing
import Foundation

@MainActor
@Suite
struct Goal_Period_TintTests {
    @Test func tintColorIsCorrectForEachPeriod() {
        let inputs: [(Goal.Period, Color, SourceLocation)] = [
            (.weekly, Color(asset: Asset.blue), #_sourceLocation),
            (.monthly, Color(asset: Asset.purple), #_sourceLocation),
            (.yearly, Color(asset: Asset.green), #_sourceLocation),
        ]

        for (period, expected, location) in inputs {
            let sut = period.tint
            #expect(sut == expected, sourceLocation: location)
        }
    }
}
