import Model
@testable import RunDetail
import Testing
import Foundation

@Suite
struct DistanceSample_SplitsTests {
    @Test func splitsFromMockData() throws {
        let run: Run = .content("long_run")
        let detail = try #require(run.detail)
        let splits = detail.distanceSamples.splits(locale: .init(identifier: "en_AU"))

        #expect(splits.count == 11)
    }
}
