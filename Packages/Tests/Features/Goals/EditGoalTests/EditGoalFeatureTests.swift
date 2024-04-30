import ComposableArchitecture
@testable import EditGoal
import Model
import Repository
import XCTest

final class EditGoalFeatureTests: XCTestCase {
    @MainActor
    func testEditingExistingGoalFlow() async throws {
        let goal: Goal = .mock(
            period: .weekly,
            target: .init(value: 100, unit: .kilometers)
        )
        let store = TestStore(
            initialState: .init(
                goal: goal
            ),
            reducer: EditGoalFeature.init,
            withDependencies: {
                $0.locale = .init(identifier: "en_AU")
            }
        )

        // setup on appearance
        await store.send(.view(.onAppear)) {
            $0.target = "100.0"
            $0.targetMeasurement = goal.target
        }

        // type incorrect value
        await store.send(.view(.targetUpdated("100d"))) {
            $0.target = "100d"
        }
        // validation called by view layer immediately
        await store.send(.view(.validateTarget)) {
            $0.target = "100"
        }

        // type correct value
        await store.send(.view(.targetUpdated("150"))) {
            $0.target = "150"
        }
        // validation called by view layer immediately
        await store.send(.view(.validateTarget)) {
            $0.targetMeasurement = .init(
                value: 150,
                unit: .kilometers
            )
        }

        // save
        await store.send(.view(.saveButtonTapped))

        let updatedGoal: Goal = .mock(
            period: .weekly,
            target: .init(value: 150, unit: .kilometers)
        )
        await store.receive(.delegate(.goalUpdated(updatedGoal)))
    }

    @MainActor
    func testClearingExistingGoalFlow() async throws {
        let goal: Goal = .mock(
            period: .weekly,
            target: .init(value: 100, unit: .kilometers)
        )
        let store = TestStore(
            initialState: .init(
                goal: goal
            ),
            reducer: EditGoalFeature.init,
            withDependencies: {
                $0.locale = .init(identifier: "en_AU")
            }
        )

        // setup on appearance
        await store.send(.view(.onAppear)) {
            $0.target = "100.0"
            $0.targetMeasurement = goal.target
        }

        await store.send(.view(.clearButtonTapped))
        await store.receive(.delegate(.goalCleared(.weekly)))
    }

    @MainActor
    func testSettingNewGoalFlow() async throws {
        let goal: Goal = .mock(
            period: .weekly,
            target: nil
        )
        let store = TestStore(
            initialState: .init(
                goal: goal
            ),
            reducer: EditGoalFeature.init,
            withDependencies: {
                $0.locale = .init(identifier: "en_AU")
            }
        )

        // setup on appearance
        await store.send(.view(.onAppear)) {
            $0.targetMeasurement = .init(
                value: 50,
                unit: .kilometers
            )
        }

        // type correct value
        await store.send(.view(.targetUpdated("150"))) {
            $0.target = "150"
        }
        // validation called by view layer immediately
        await store.send(.view(.validateTarget)) {
            $0.targetMeasurement = .init(
                value: 150,
                unit: .kilometers
            )
        }

        // save
        await store.send(.view(.saveButtonTapped))

        let updatedGoal: Goal = .mock(
            period: .weekly,
            target: .init(value: 150, unit: .kilometers)
        )
        await store.receive(.delegate(.goalUpdated(updatedGoal)))
    }
}
