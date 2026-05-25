@testable import HealthKitServiceInterface
import Testing
import Foundation
import XCTestDynamicOverlay

@Suite
struct RunningWorkoutsTests {
    @Test func allRunningWorkoutsPublicHelper() async throws {
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

        let sut: HealthKitRunningWorkouts = .init(
            allRunningWorkouts: { workouts },
            detail: unimplemented()
        )

        let allRunningWorkouts = try await sut.allRunningWorkouts()
        let allMockRunningWorkouts = allRunningWorkouts.compactMap { $0 as? MockWorkoutType }
        #expect(allMockRunningWorkouts == workouts)
    }
}
