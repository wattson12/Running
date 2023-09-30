import ComposableArchitecture
import Foundation
import Model

public struct RunDetailFeature: Reducer {
    public struct State: Equatable {
        let run: Run

        public init(
            run: Run
        ) {
            self.run = run
        }
    }

    public enum Action: Equatable {
        public enum View: Equatable {}

        case view(View)
    }

    public init() {}

    public var body: some ReducerOf<Self> {
        EmptyReducer()
    }
}
