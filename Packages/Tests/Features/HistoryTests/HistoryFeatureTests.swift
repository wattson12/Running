import ComposableArchitecture
import Dependencies
@testable import History
import Model
import Repository
import XCTest

@MainActor
final class HistoryFeatureTests: XCTestCase {
    func testHistoryIsSetCorrectlyOnAppearanceWhenCachedRunsAreEmpty() async throws {
        let store = TestStore(
            initialState: .init(),
            reducer: HistoryFeature.init,
            withDependencies: {
                $0.repository.runningWorkouts._allRunningWorkouts = {
                    .init(cache: { nil }, remote: { [] })
                }
            }
        )

        await store.send(.view(.onAppear))
    }

    func testHistoryIsSetCorrectlyOnAppearanceWhenThereAreCachedRuns() async throws {
        let runs: [Run] = [
            .init(
                id: .init(),
                startDate: .init(timeIntervalSince1970: 947_022_395),
                distance: .init(value: 10, unit: .kilometers),
                duration: .init(value: 10, unit: .seconds),
                detail: nil
            ),
            .init(
                id: .init(),
                startDate: .init(timeIntervalSince1970: 978_644_795),
                distance: .init(value: 10, unit: .kilometers),
                duration: .init(value: 10, unit: .seconds),
                detail: nil
            ),
        ]

        let id: UUID = .init()

        let store = TestStore(
            initialState: .init(),
            reducer: HistoryFeature.init,
            withDependencies: {
                $0.repository.runningWorkouts._allRunningWorkouts = {
                    .init(cache: { runs }, remote: { [] })
                }
                $0.uuid = .constant(id)
                $0.calendar = .current
            }
        )

        await store.send(.view(.onAppear)) {
            $0.totals = [
                .init(id: id, period: .yearly, label: "2000", sort: 2000, distance: .init(value: 10, unit: .kilometers)),
                .init(id: id, period: .yearly, label: "2001", sort: 2001, distance: .init(value: 10, unit: .kilometers)),
            ]

            $0.summary = .init(
                distance: .init(value: 20, unit: .kilometers),
                duration: .init(value: 20, unit: .seconds),
                count: 2
            )
        }
    }

    func testSortByDateUpdatesSortCorrectly() async throws {
        let total1: IntervalTotal = .init(
            id: .init(),
            period: .yearly,
            label: UUID().uuidString,
            sort: 10,
            distance: .init(value: 1, unit: .kilometers)
        )

        let total2: IntervalTotal = .init(
            id: .init(),
            period: .yearly,
            label: UUID().uuidString,
            sort: 1,
            distance: .init(value: 100, unit: .kilometers)
        )

        let store = TestStore(
            initialState: .init(
                totals: [total1, total2],
                sortType: .distance
            ),
            reducer: HistoryFeature.init
        )

        await store.send(.view(.sortByDateMenuButtonTapped)) {
            $0.totals = [total2, total1]
            $0.sortType = .date
        }
    }

    func testSortBySistanceUpdatesSortCorrectly() async throws {
        let total1: IntervalTotal = .init(
            id: .init(),
            period: .yearly,
            label: UUID().uuidString,
            sort: 10,
            distance: .init(value: 100, unit: .kilometers)
        )

        let total2: IntervalTotal = .init(
            id: .init(),
            period: .yearly,
            label: UUID().uuidString,
            sort: 1,
            distance: .init(value: 1, unit: .kilometers)
        )

        let store = TestStore(
            initialState: .init(
                totals: [total2, total1],
                sortType: .date
            ),
            reducer: HistoryFeature.init
        )

        await store.send(.view(.sortByDistanceMenuButtonTapped)) {
            $0.totals = [total1, total2]
            $0.sortType = .distance
        }
    }
}
