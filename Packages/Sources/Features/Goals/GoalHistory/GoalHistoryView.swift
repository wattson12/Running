import ComposableArchitecture
import SwiftUI

@Reducer
public struct GoalHistoryFeature {
    public struct State: Equatable {
        public init() {}
    }

    public enum Action {}

    public var body: some ReducerOf<Self> {
        EmptyReducer()
    }
}

public struct GoalHistoryView: View {
    let store: StoreOf<GoalHistoryFeature>

    public var body: some View {
        Text("Goal History")
    }
}

#Preview {
    GoalHistoryView(
        store: .init(
            initialState: .init(),
            reducer: GoalHistoryFeature.init
        )
    )
}
