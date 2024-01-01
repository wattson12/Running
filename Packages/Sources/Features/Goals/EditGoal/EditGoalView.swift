import ComposableArchitecture
import Model
import Repository
import Resources
import SwiftUI

public struct EditGoalView: View {
    @State var store: StoreOf<EditGoalFeature>

    @FocusState var focussed: Bool
    @Environment(\.locale) var locale

    public init(store: StoreOf<EditGoalFeature>) {
        _store = .init(initialValue: store)
    }

    public var body: some View {
        NavigationStack {
            VStack {
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    TextField(
                        "",
                        text: $store.target.sending(\.view.targetUpdated)
                    )
                    .onChange(of: store.target) { _, _ in
                        store.send(.view(.validateTarget))
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

                if let initial = store.initialGoal.target {
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
                        store.send(.view(.saveButtonTapped))
                    },
                    label: {
                        Text(
                            store.initialGoal.target == nil
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

                if store.initialGoal.target != nil {
                    Button(
                        role: .destructive,
                        action: {
                            store.send(.view(.clearButtonTapped))
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
                store.initialGoal.target == nil
                    ? L10n.Goals.Edit.setGoal
                    : L10n.Goals.Edit.updateGoal
            )
            .onAppear {
                focussed = true
                store.send(.view(.onAppear))
            }
        }
        .tint(store.period.tint)
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
