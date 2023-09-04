import Foundation
import IdentifiedCollections

struct Acknowledgement: Identifiable, Equatable {
    let name: String
    let url: URL

    var id: String { name }
}

extension IdentifiedArrayOf<Acknowledgement> {
    static let acknowledgements: Self = [
        .init(
            name: "The Composable Architecture",
            url: URL(string: "https://github.com/pointfreeco/swift-composable-architecture")!
        ),
        .init(
            name: "Dependencies",
            url: URL(string: "https://github.com/pointfreeco/swift-dependencies")!
        ),
        .init(
            name: "Dependencies Additions",
            url: URL(string: "https://github.com/tgrapperon/swift-dependencies-additions")!
        ),
        .init(
            name: "swift-url-routing",
            url: URL(string: "https://github.com/pointfreeco/swift-url-routing")!
        ),
    ]
}
