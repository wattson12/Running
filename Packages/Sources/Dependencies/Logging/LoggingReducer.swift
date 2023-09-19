import ComposableArchitecture
import Foundation

public struct _LoggingReducer<R: Reducer>: Reducer {
    let base: R

    public init(base: R) {
        self.base = base
    }

    @Dependency(\.logStore) var logStore
    @Dependency(\.date) var date
    @Dependency(\.uuid) var uuid

    public func reduce(into state: inout R.State, action: R.Action) -> Effect<R.Action> {
        let originalState = state
        let baseEffect = base.reduce(into: &state, action: action)

        return baseEffect
            .merge(
                with: .run { [newState = state] _ in
                    logStore.append(
                        log: log(
                            originalState: originalState,
                            newState: newState,
                            action: action
                        )
                    )
                }
            )
    }

    private func log(originalState: R.State, newState: R.State, action: R.Action) -> ActionLog {
        var actionDump = ""
        CustomDump.customDump(action, to: &actionDump, indent: 4)

        let label = debugCaseOutput(action)

        return ActionLog(
            id: uuid(),
            timestamp: date.now,
            actionLabel: label,
            action: actionDump,
            stateDiff: diff(originalState, newState)
        )
    }
}

public extension Reducer {
    func _logging() -> _LoggingReducer<Self> {
        _LoggingReducer(base: self)
    }
}
