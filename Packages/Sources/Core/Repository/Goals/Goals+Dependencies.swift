import Foundation
import Model
import XCTestDynamicOverlay

extension Goals {
    public static func mock(goals: [Goal]) -> Goals {
        var goals = goals

        return .init(
            goal: { period in
                goals.first(where: { $0.period == period })!
            },
            updateGoal: { goal in
                guard let index = goals.firstIndex(where: { $0.period == goal.period }) else { return }
                goals[index] = goal
            }
        )
    }

    static var previewValue: Goals = .mock(
        goals: [
            .init(period: .weekly, target: .init(value: 50, unit: .kilometers)),
            .init(period: .monthly, target: nil),
            .init(period: .yearly, target: .init(value: 1500, unit: .kilometers)),
        ]
    )

    static var testValue: Goals = .init()
}
