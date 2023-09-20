import ComposableArchitecture
import Foundation

public struct LogDetailFeature: Reducer {
    public struct State: Equatable {
        struct IndexedElement: Equatable, Identifiable {
            let label: String
            let index: Int
            let element: String
            var id: String { label + index.description }
        }

        let actionLabel: String
        let actionLines: [IndexedElement]
        let diffLines: [IndexedElement]?

        init(log: ActionLog) {
            actionLabel = log.actionLabel
            actionLines = log.action
                .components(separatedBy: .newlines)
                .enumerated()
                .map { index, element in
                    IndexedElement(
                        label: "action",
                        index: index,
                        element: element
                    )
                }

            diffLines = log.stateDiff?
                .components(separatedBy: .newlines)
                .enumerated()
                .map { index, element in
                    IndexedElement(
                        label: "diff",
                        index: index,
                        element: element
                    )
                }
        }
    }

    public typealias Action = Never

    public var body: some ReducerOf<Self> {
        EmptyReducer()
    }
}
