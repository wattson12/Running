import ComposableArchitecture
import Dependencies
import DependenciesAdditions
import Foundation
import Model

extension UserDefaults.Dependency {
    func logging() -> ObservationLogging? {
        guard let data = data(forKey: "observation_logging") else { return nil }
        guard let decodedValue = try? JSONDecoder().decode(ObservationLogging.self, from: data) else { return nil }
        return decodedValue
    }
}

struct IdentifiedMessage: Identifiable, Equatable {
    let id: UUID
    let date: Date
    let message: String

    init(message: ObservationLogging.Message) {
        id = .init()
        date = message.date
        self.message = message.message
    }
}

public struct DebugFeature: Reducer {
    public struct State: Equatable {
        var messages: [IdentifiedMessage] = []
        var searchText: String = ""

        var filteredMessages: [IdentifiedMessage] {
            guard !searchText.isEmpty else { return messages }

            return messages.filter { message in
                message.message.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    public enum Action: Equatable {
        public enum View: Equatable {
            case onAppear
            case searchTextUpdated(String)
        }

        case view(View)
    }

    @Dependency(\.userDefaults) var userDefaults

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .view(action):
                return view(action, state: &state)
            }
        }
    }

    private func view(_ action: Action.View, state: inout State) -> Effect<Action> {
        switch action {
        case .onAppear:
            // log current messages
            guard let logging = userDefaults.logging() else { return .none }
            state.messages = logging.messages.map(IdentifiedMessage.init)
            return .none
        case let .searchTextUpdated(text):
            state.searchText = text
            return .none
        }
    }
}
