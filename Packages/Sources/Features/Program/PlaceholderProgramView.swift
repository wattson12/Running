import ComposableArchitecture
import SwiftUI

@Reducer
public struct PlaceholderProgramFeature {
    public struct State: Equatable {
        public init() {}
    }

    public enum Action: Equatable, ViewAction {
        public enum View: Equatable {}
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
