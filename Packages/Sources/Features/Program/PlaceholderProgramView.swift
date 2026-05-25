import ComposableArchitecture
import SwiftUI

@Reducer
public struct PlaceholderProgramFeature {
    public struct State: Equatable, Sendable {
        public init() {}
    }

    public enum Action: ViewAction, Sendable {
        public enum View: Sendable {}
        case view(View)
    }

    public init() {}
}

@ViewAction(for: PlaceholderProgramFeature.self)
public struct PlaceholderProgramView: View {
    public let store: StoreOf<PlaceholderProgramFeature>

    public init(store: StoreOf<PlaceholderProgramFeature>) {
        self.store = store
    }

    public var body: some View {
        Text("Program")
    }
}

#Preview {
    PlaceholderProgramView(
        store: .init(
            initialState: .init(),
            reducer: PlaceholderProgramFeature.init
        )
    )
}
