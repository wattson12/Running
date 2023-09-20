import Foundation

public struct ActionLog: Equatable, Identifiable, Encodable {
    public let id: UUID
    public let timestamp: Date
    public let actionLabel: String
    public let action: String
    public let stateDiff: String?

    public init(
        id: UUID,
        timestamp: Date,
        actionLabel: String,
        action: String,
        stateDiff: String?
    ) {
        self.id = id
        self.timestamp = timestamp
        self.actionLabel = actionLabel
        self.action = action
        self.stateDiff = stateDiff
    }
}

public extension ActionLog {
    static func mock(
        id: UUID = .init(),
        timestamp: Date = .now,
        actionLabel: String = "Action.View.onAppear",
        action: String = "Action.View.onAppear",
        stateDiff: String? = nil
    ) -> Self {
        .init(
            id: id,
            timestamp: timestamp,
            actionLabel: actionLabel,
            action: action,
            stateDiff: stateDiff
        )
    }
}
