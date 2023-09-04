@testable import HealthKitServiceInterface
import XCTest

final class RunningWorkoutsTests: XCTestCase {
    func testAllRunningWorkoutsPublicHelper() async throws {
        let workouts: [MockWorkoutType] = [
            .init(
                duration: .random(in: 1 ..< 100),
                distance: .random(in: 1 ..< 100)
            ),
            .init(
                duration: .random(in: 1 ..< 100),
                distance: .random(in: 1 ..< 100)
            ),
        ]

        let sut: HealthKitRunningWorkouts = .init(allRunningWorkouts: { workouts })

        let allRunningWorkouts = try await sut.allRunningWorkouts()
        let allMockRunningWorkouts = allRunningWorkouts.compactMap { $0 as? MockWorkoutType }
        XCTAssertEqual(allMockRunningWorkouts, workouts)
    }
}
