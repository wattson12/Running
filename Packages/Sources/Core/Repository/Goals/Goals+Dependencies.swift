import Foundation
import Model
import XCTestDynamicOverlay
import ConcurrencyExtras

extension Goals {
    public static func mock(goals: [Goal]) -> Goals {
        let goals = LockIsolated(goals)

        return .init(
            goal: { period in
                goals.value.first(where: { $0.period == period })!
            },
            updateGoal: { goal in
                guard let index = goals.value.firstIndex(where: { $0.period == goal.period }) else { return }
                goals.withValue { $0[index] = goal }
            }
        )
    }

    static let previewValue: Goals = .mock(
        goals: [
            .init(period: .weekly, target: .init(value: 50, unit: .kilometers)),
            .init(period: .monthly, target: nil),
            .init(period: .yearly, target: .init(value: 1500, unit: .kilometers)),
        ]
    )

    static let testValue: Goals = .init()
}
