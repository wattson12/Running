import ComposableArchitecture
import Resources
import SwiftUI

struct DebugView: View {
    struct ViewState: Equatable {
        let messages: [IdentifiedMessage]
        let searchText: String

        init(state: DebugFeature.State) {
            messages = state.filteredMessages
            searchText = state.searchText
        }
    }

    let store: StoreOf<DebugFeature>

    var body: some View {
        WithViewStore(
            store,
            observe: ViewState.init,
            send: DebugFeature.Action.view
        ) { viewStore in
            List(viewStore.messages) { message in
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(message.date, style: .date)
                        Text(message.date, style: .time)
                    }
                    .font(.headline)

                    Text(message.message)
                        .multilineTextAlignment(.leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .listStyle(.plain)
            .searchable(
                text: viewStore.binding(
                    get: \.searchText,
                    send: DebugFeature.Action.View.searchTextUpdated
                )
            )
            .navigationTitle(L10n.App.Feature.debug)
            .onAppear { viewStore.send(.onAppear) }
        }
    }
}

#Preview {
    NavigationStack {
        DebugView(
            store: .init(
                initialState: .init(
                    messages: [
                        .init(
                            message: .init(
                                date: Date(),
                                message: "test"
                            )
                        ),
                        .init(
                            message: .init(
                                date: Date(),
                                message: "this is a much longer message which should take up multiple liens of text and be wrapped so you can still see all of it since there might be an error at the end. Error = Optional(ForEach<Array<Message>, Date, Text>: the ID 2023-08-31 20:37:22 +0000 occurs multiple times within the collection, this will give undefined results!)"
                            )
                        ),
                    ]
                ),
                reducer: DebugFeature.init
            )
        )
    }
}
