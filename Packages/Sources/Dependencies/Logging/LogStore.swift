import Foundation

public struct LogStore: Sendable {
    public var _append: @Sendable (ActionLog) -> Void
    public var _logs: @Sendable () -> [ActionLog]

    public init(
        append: @Sendable @escaping (ActionLog) -> Void,
        logs: @Sendable @escaping () -> [ActionLog]
    ) {
        _append = append
        _logs = logs
    }
}

public extension LogStore {
    func append(log: ActionLog) {
        _append(log)
    }

    func logs() -> [ActionLog] {
        _logs()
    }
}
