import ComposableArchitecture
import Model
import Repository
@testable import RunDetail
import XCTest

@MainActor
final class RunDetailFeatureTests: XCTestCase {
    func testRunIsFetchedWithLoadingStateIfRunHasNoDetail() async throws {
        let initialRun: Run = .mock(detail: nil)
        let runWithDetail: Run = .mock(detail: .mock())

        let store = TestStore(
            initialState: .init(run: initialRun),
            reducer: RunDetailFeature.init,
            withDependencies: {
                $0.repository.runningWorkouts._runDetail = { _ in runWithDetail }
            }
        )

        await store.send(.view(.onAppear)) {
            $0.isLoading = true
        }

        await store.receive(._internal(.runDetailFetched(.success(runWithDetail)))) {
            $0.isLoading = false
            $0.run = runWithDetail
        }
    }

    func testRunIsFetchedWithoutLoadingStateIfRunHasDetail() async throws {
        let initialRun: Run = .mock(detail: .mock())
        let updatedRun: Run = .mock(detail: .mock())

        let store = TestStore(
            initialState: .init(run: initialRun),
            reducer: RunDetailFeature.init,
            withDependencies: {
                $0.repository.runningWorkouts._runDetail = { _ in updatedRun }
            }
        )

        await store.send(.view(.onAppear))

        await store.receive(._internal(.runDetailFetched(.success(updatedRun)))) {
            $0.run = updatedRun
        }
    }

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
