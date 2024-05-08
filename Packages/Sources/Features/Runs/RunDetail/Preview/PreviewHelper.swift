import Foundation
import Model

extension Run {
    static func preview(_ name: String) -> Run {
        guard let url = Bundle.module.url(forResource: name, withExtension: "json") else { return .mock() }
        guard let data = try? Data(contentsOf: url) else { return .mock() }
        guard let run = try? JSONDecoder().decode(Run.self, from: data) else { return .mock() }
        return run
    }
}
