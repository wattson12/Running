import ComposableArchitecture
import Foundation

struct ActionLog: Equatable, CustomStringConvertible {
    let timestamp: Date
    let actionLabel: String
    let action: String
    let stateChange: [String]

    var description: String {
        if stateChange.isEmpty {
            return """
            \(actionLabel)
            action:
            \(action)
            """
        } else {
            return """
            \(actionLabel)
            action:
            \(action)
            state:
            \(stateChange.joined(separator: "\n"))
            """
        }
    }
}
