import ComposableArchitecture
import Foundation

public struct LogDetailFeature: Reducer {
    public typealias State = ActionLog
    public typealias Action = Never

    public var body: some ReducerOf<Self> {
        EmptyReducer()
    }
}
