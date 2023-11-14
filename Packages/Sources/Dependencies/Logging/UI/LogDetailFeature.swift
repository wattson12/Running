import ComposableArchitecture
import Foundation

@Reducer
public struct LogDetailFeature {
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

        var actionExpanded: Bool = false
        var diffExpanded: Bool = false

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

            actionExpanded = actionLines.count < 20
            diffExpanded = diffLines?.count ?? 0 < 20
        }
    }

    public enum Action: Equatable {
        public enum View: Equatable {
            case toggleActionExpandedTapped
            case toggleDiffExpandedTapped
        }

        case view(View)
    }

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .view(action):
                return view(action, state: &state)
            }
        }
    }

    private func view(_ action: Action.View, state: inout State) -> EffectOf<Self> {
        switch action {
        case .toggleActionExpandedTapped:
            state.actionExpanded.toggle()
            return .none
        case .toggleDiffExpandedTapped:
            state.diffExpanded.toggle()
            return .none
        }
    }
}
