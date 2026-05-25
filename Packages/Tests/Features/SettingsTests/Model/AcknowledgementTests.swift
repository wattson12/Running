import IdentifiedCollections
@testable import Settings
import Testing
import Foundation

@Suite
struct AcknowledgementTests {
    func testDefaultArrayIsCorrect() {
        let sut: IdentifiedArrayOf<Acknowledgement> = .acknowledgements
        guard sut.count == 4 else {
            Issue.record("Incorrect count, expected 4 but found \(sut.count)")
            return
        }

        #expect(sut[0].name == "The Composable Architecture")
        #expect(sut[0].url == URL(string: "https://github.com/pointfreeco/swift-composable-architecture"))

        #expect(sut[1].name == "Dependencies")
        #expect(sut[1].url == URL(string: "https://github.com/pointfreeco/swift-dependencies"))

        #expect(sut[2].name == "Dependencies Additions")
        #expect(sut[2].url == URL(string: "https://github.com/tgrapperon/swift-dependencies-additions"))

        #expect(sut[3].name == "swift-url-routing")
        #expect(sut[3].url == URL(string: "https://github.com/pointfreeco/swift-url-routing"))
    }
}
