import ComposableArchitecture
import DesignSystem
import EditGoal
import GoalDetail
import Model
import Repository
import Resources
import SwiftUI

public struct GoalListView: View {
    let store: StoreOf<GoalListFeature>

    public init(
        store: StoreOf<GoalListFeature>
    ) {
        self.store = store
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(store.rows) { row in
                    GoalRowView(
                        goal: row.goal,
                        distance: row.distance,
                        action: {
                            store.send(.view(.goalTapped(row.goal)))
                        },
                        editAction: {
                            store.send(.view(.editTapped(row.goal)))
                        }
                    )
                    .customTint(row.goal.period.tint)
                }
            }
        }
        .navigationTitle(L10n.App.Feature.goals)
        .onAppear { store.send(.view(.onAppear)) }
        .navigationDestination(
            store: store.scope(
                state: \.$destination.detail,
                action: \.destination.detail
            ),
            destination: GoalDetailView.init
        )
        .sheet(
            store: store.scope(
                state: \.$destination.editGoal,
                action: \.destination.editGoal
            ),
            content: { store in
                EditGoalView(store: store)
                    .presentationDetents([.medium])
            }
        )
    }
}

struct GoalListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            GoalListView(
                store: .init(
                    initialState: .init(),
                    reducer: GoalListFeature.init,
                    withDependencies: {
                        $0.date = .constant(.preview)
                        $0.locale = .init(identifier: "en_AU")
                    }
                )
            )
        }
        .environment(\.locale, .init(identifier: "en_AU"))

        NavigationStack {
            UpdatedGoalPreviewWrapper(
                store: .init(
                    initialState: .init(goalList: .init()),
                    reducer: UpdatedGoalPreviewWrapperFeature.init,
                    withDependencies: {
                        $0.date = .constant(.preview)
                        $0.locale = .init(identifier: "en_AU")

                        $0.repository.runningWorkouts._allRunningWorkouts = {
                            .mock(value: [], delay: 2)
                        }
                    }
                )
            )
        }
        .environment(\.locale, .init(identifier: "en_AU"))
        .previewDisplayName("Updated Goal")
    }
}
