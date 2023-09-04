@testable import Model
import Resources
import SwiftUI
import XCTest

final class Goal_Period_TintTests: XCTestCase {
    func testTintColorIsCorrectForEachPeriod() {
        let inputs: [(Goal.Period, Color, UInt)] = [
            (.weekly, Color(asset: Asset.blue), #line),
            (.monthly, Color(asset: Asset.purple), #line),
            (.yearly, Color(asset: Asset.green), #line),
        ]

        for (period, expected, line) in inputs {
            let sut = period.tint
            XCTAssertEqual(sut, expected, line: line)
        }
    }
}
