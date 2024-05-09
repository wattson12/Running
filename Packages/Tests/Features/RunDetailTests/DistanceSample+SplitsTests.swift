import Model
@testable import RunDetail
import XCTest

final class DistanceSample_SplitsTests: XCTestCase {
    func testSplitsFromMockData() throws {
        let run: Run = .content("long_run")
        let detail = try XCTUnwrap(run.detail)
        let splits = detail.distanceSamples.splits(locale: .init(identifier: "en_AU"))

        XCTAssertEqual(splits.count, 11)
    }
}
