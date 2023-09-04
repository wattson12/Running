import IdentifiedCollections
@testable import Settings
import XCTest

final class AcknowledgementTests: XCTestCase {
    func testDefaultArrayIsCorrect() {
        let sut: IdentifiedArrayOf<Acknowledgement> = .acknowledgements
        guard sut.count == 4 else {
            XCTFail("Incorrect count, expected 4 but found \(sut.count)")
            return
        }

        XCTAssertEqual(sut[0].name, "The Composable Architecture")
        XCTAssertEqual(sut[0].url, URL(string: "https://github.com/pointfreeco/swift-composable-architecture"))

        XCTAssertEqual(sut[1].name, "Dependencies")
        XCTAssertEqual(sut[1].url, URL(string: "https://github.com/pointfreeco/swift-dependencies"))

        XCTAssertEqual(sut[2].name, "Dependencies Additions")
        XCTAssertEqual(sut[2].url, URL(string: "https://github.com/tgrapperon/swift-dependencies-additions"))

        XCTAssertEqual(sut[3].name, "swift-url-routing")
        XCTAssertEqual(sut[3].url, URL(string: "https://github.com/pointfreeco/swift-url-routing"))
    }
}
