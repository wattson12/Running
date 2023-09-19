import ComposableArchitecture
import SwiftUI

struct LogListFeature: Reducer {
    struct State: Equatable {
        var logs: [ActionLog] = []
    }

    enum Action: Equatable {
        enum View: Equatable {
            case onAppear
            case refreshButtonTapped
        }

        case view(View)
    }

    @Dependency(\.logStore) var logStore

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .view(action):
                return view(action, state: &state)
            }
        }
    }

    private func view(_ action: Action.View, state: inout State) -> EffectOf<Self> {
        switch action {
        case .onAppear:
            refreshLogs(&state)
            return .none
        case .refreshButtonTapped:
            refreshLogs(&state)
            return .none
        }
    }

    private func refreshLogs(_ state: inout State) {
        state.logs = logStore.logs()
    }
}

struct LogListView: View {
    struct ViewState: Equatable {
        let logs: [ActionLog]

        init(state: LogListFeature.State) {
            logs = state.logs
        }
    }

    let store: StoreOf<LogListFeature>

    var body: some View {
        WithViewStore(
            store,
            observe: ViewState.init,
            send: LogListFeature.Action.view
        ) { viewStore in
            NavigationStack {
                List(viewStore.logs) { log in
                    Text(log.actionLabel)
                }
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(
                            action: {
                                viewStore.send(.refreshButtonTapped)
                            },
                            label: {
                                Image(systemName: "arrow.counterclockwise")
                            }
                        )
                    }
                }
                .navigationTitle("Logs")
            }
            .onAppear { viewStore.send(.onAppear) }
        }
    }
}

#Preview {
    LogListView(
        store: .init(
            initialState: .init(),
            reducer: { LogListFeature()._logging() }
        )
    )
}
