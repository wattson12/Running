import ComposableArchitecture
import Model
import Repository
@testable import RunDetail
import XCTest

final class RunDetailFeatureTests: XCTestCase {
    @MainActor
    func testRunIsFetchedWithLoadingStateIfRunHasNoDetail() async throws {
        let initialRun: Run = .mock(detail: nil)
        let runWithDetail: Run = .mock(detail: .mock())

        let store = TestStore(
            initialState: .init(run: initialRun),
            reducer: RunDetailFeature.init,
            withDependencies: {
                $0.repository.runningWorkouts._runDetail = { _ in runWithDetail }
                $0.repository.runningWorkouts._cachedRun = { _ in initialRun }
                $0.locale = .init(identifier: "en_AU")
            }
        )

        await store.send(.view(.onAppear)) {
            $0.isLoading = true
        }

        await store.receive(._internal(.runDetailFetched(.success(initialRun))))

        await store.receive(.delegate(.runDetailFetched(initialRun)))

        await store.receive(._internal(.runDetailFetched(.success(runWithDetail)))) {
            $0.isLoading = false
            $0.splits = [
                Split(
                    distance: "1",
                    duration: 684.289705991745
                ),
                Split(
                    distance: "2",
                    duration: 656.0492275953293
                ),
                Split(
                    distance: "3",
                    duration: 630.354817032814
                ),
                Split(
                    distance: "4",
                    duration: 1042.9147888422012
                ),
            ]
            $0.run = runWithDetail
        }

        await store.receive(.delegate(.runDetailFetched(runWithDetail)))
    }

    @MainActor
    func testRunIsFetchedWithoutLoadingStateIfRunHasDetail() async throws {
        let initialRun: Run = .mock(detail: .mock())
        let updatedRun: Run = .mock(detail: .mock())

        let store = TestStore(
            initialState: .init(run: initialRun),
            reducer: RunDetailFeature.init,
            withDependencies: {
                $0.repository.runningWorkouts._runDetail = { _ in updatedRun }
                $0.repository.runningWorkouts._cachedRun = { _ in initialRun }
                $0.locale = .current
            }
        )

        await store.send(.view(.onAppear))

        await store.receive(._internal(.runDetailFetched(.success(initialRun)))) {
            $0.splits = [
                Split(
                    distance: "1",
                    duration: 1089.1948469877243
                ),
                Split(
                    distance: "2",
                    duration: 1014.739447593689
                ),
            ]
        }

        await store.receive(.delegate(.runDetailFetched(initialRun)))

        await store.receive(._internal(.runDetailFetched(.success(updatedRun)))) {
            $0.run = updatedRun
        }

        await store.receive(.delegate(.runDetailFetched(updatedRun)))
    }

    @MainActor
    func testFailedDetailFetchClearsLoadingState() async throws {
        let store = TestStore(
            initialState: .init(
                run: .mock(),
                isLoading: true
            ),
            reducer: RunDetailFeature.init
        )

        let error = NSError(domain: #fileID, code: #line)
        await store.send(._internal(.runDetailFetched(.failure(error)))) {
            $0.isLoading = false
        }
    }
}
