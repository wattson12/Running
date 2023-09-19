import ComposableArchitecture
import Foundation

struct LogDetailFeature: Reducer {
    typealias State = ActionLog
    typealias Action = Never

    var body: some ReducerOf<Self> {
        EmptyReducer()
    }
}
