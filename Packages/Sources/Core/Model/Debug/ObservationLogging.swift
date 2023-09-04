import Foundation

public struct ObservationLogging: Codable, Equatable {
    public struct Message: Codable, Equatable {
        public let date: Date
        public let message: String

        public init(
            date: Date,
            message: String
        ) {
            self.date = date
            self.message = message
        }
    }

    public var messages: [Message]

    public init(
        messages: [Message]
    ) {
        self.messages = messages
    }
}
