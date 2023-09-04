import ComposableArchitecture
import Model
import Repository
import Resources
import SwiftUI

public struct EditGoalView: View {
    struct ViewState: Equatable {
        let period: Goal.Period
        let initialTarget: Measurement<UnitLength>?
        let target: String

        init(state: EditGoalFeature.State) {
            period = state.period
            initialTarget = state.initialGoal.target
            target = state.target
        }
    }

    let store: StoreOf<EditGoalFeature>
    @FocusState var focussed: Bool
    @Environment(\.locale) var locale

    public init(store: StoreOf<EditGoalFeature>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(
            store,
            observe: ViewState.init,
            send: EditGoalFeature.Action.view
        ) { viewStore in
            NavigationStack {
                VStack {
                    HStack(alignment: .firstTextBaseline, spacing: 2) {
                        TextField(
                            "",
                            text: viewStore.binding(
                                get: \.target,
                                send: {
                                    .targetUpdated($0)
                                }
                            )
                        )
                        .onChange(of: viewStore.target) { _, _ in
                            viewStore.send(.validateTarget)
                        }
                        .keyboardType(.numberPad)
                        .focused($focussed)
                        .font(.largeTitle)
                        .frame(height: 80)
                        .fixedSize()

                        Text(UnitLength.primaryUnit(locale: locale).symbol)
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }

                    if let initial = viewStore.initialTarget {
                        Text(
                            L10n.Goals.Edit.previousGoalFormat(
                                initial
                                    .converted(to: .primaryUnit(locale: locale))
                                    .fullValue(locale: locale)
                            )
                        )
                        .font(.body)
                        .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Button(
                        action: {
                            viewStore.send(.saveButtonTapped)
                        },
                        label: {
                            Text(
                                viewStore.initialTarget == nil
                                    ? L10n.Goals.Edit.setGoal
                                    : L10n.Goals.Edit.updateGoal
                            )
                            .font(.title3.bold())
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                        }
                    )
                    .buttonStyle(.borderedProminent)

                    if viewStore.initialTarget != nil {
                        Button(
                            role: .destructive,
                            action: {
                                viewStore.send(.saveButtonTapped)
                            },
                            label: {
                                Text(L10n.Goals.Edit.Button.clear)
                                    .font(.title3)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 44)
                            }
                        )
                        .tint(.red)
                    }
                }
                .padding()
                .navigationTitle(
                    viewStore.initialTarget == nil
                        ? L10n.Goals.Edit.setGoal
                        : L10n.Goals.Edit.updateGoal
                )
                .onAppear {
                    focussed = true
                    viewStore.send(.onAppear)
                }
            }
            .tint(viewStore.period.tint)
        }
    }
}

struct EditGoalView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            EditGoalView(
                store: .init(
                    initialState: .init(
                        goal: .init(
                            period: .yearly,
                            target: .init(
                                value: 1000,
                                unit: .kilometers
                            )
                        )
                    ),
                    reducer: EditGoalFeature.init,
                    withDependencies: {
                        $0.locale = .init(identifier: "en_AU")
                    }
                )
            )
            .environment(\.locale, .init(identifier: "en_AU"))
        }
        .previewDisplayName("Editing")

        NavigationStack {
            EditGoalView(
                store: .init(
                    initialState: .init(
                        goal: .init(
                            period: .yearly,
                            target: nil
                        )
                    ),
                    reducer: EditGoalFeature.init,
                    withDependencies: {
                        $0.locale = .init(identifier: "en_AU")
                    }
                )
            )
        }
        .previewDisplayName("New Goal")

        NavigationStack {
            EditGoalView(
                store: .init(
                    initialState: .init(
                        goal: .init(
                            period: .yearly,
                            target: .init(
                                value: 1000,
                                unit: .kilometers
                            )
                        )
                    ),
                    reducer: EditGoalFeature.init,
                    withDependencies: {
                        $0.locale = .current
                    }
                )
            )
        }
        .previewDisplayName("Editing (Imperial)")
    }
}
