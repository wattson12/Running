import Dependencies
import Foundation

extension LogStore {
    static func live() -> LogStore {
        let logs: LockIsolated<[ActionLog]> = .init([])
        return .init(
            append: { log in
                logs.withValue { $0.append(log) }
            },
            logs: {
                logs.value
            }
        )
    }
}

enum LogStoreDependencyKey: DependencyKey {
    static var liveValue: LogStore = .live()
    static var previewValue: LogStore = .live()

    static var testValue: LogStore = .init(
        append: { _ in },
        logs: { [] }
    )
}

public extension DependencyValues {
    var logStore: LogStore {
        get { self[LogStoreDependencyKey.self] }
        set { self[LogStoreDependencyKey.self] = newValue }
    }
}
