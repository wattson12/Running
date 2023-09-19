import ComposableArchitecture
import SwiftUI

public struct LogListView: View {
    struct ViewState: Equatable {
        let logs: [ActionLog]

        init(state: LogListFeature.State) {
            logs = state.logs
        }
    }

    let store: StoreOf<LogListFeature>

    public init(
        store: StoreOf<LogListFeature>
    ) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(
            store,
            observe: ViewState.init,
            send: LogListFeature.Action.view
        ) { viewStore in
            NavigationStack {
                List(viewStore.logs) { log in
                    Button(
                        action: {
                            viewStore.send(.logTapped(log))
                        },
                        label: {
                            Text(log.actionLabel)
                        }
                    )
                    .buttonStyle(.plain)
                }
                .navigationDestination(
                    store: store.scope(
                        state: \.$destination,
                        action: LogListFeature.Action.destination
                    ),
                    state: /LogListFeature.Destination.State.detail,
                    action: LogListFeature.Destination.Action.detail,
                    destination: LogDetailView.init
                )
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
