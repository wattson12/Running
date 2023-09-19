import Foundation

public struct ActionLog: Equatable, Identifiable {
    public let id: UUID
    public let timestamp: Date
    public let actionLabel: String
    public let action: String
    public let stateDiff: [String]?

    public init(
        id: UUID,
        timestamp: Date,
        actionLabel: String,
        action: String,
        stateDiff: [String]?
    ) {
        self.id = id
        self.timestamp = timestamp
        self.actionLabel = actionLabel
        self.action = action
        self.stateDiff = stateDiff
    }
}
