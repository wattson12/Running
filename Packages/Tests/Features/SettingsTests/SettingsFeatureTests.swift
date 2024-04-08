import ComposableArchitecture
import DependenciesAdditions
@testable import Settings
import XCTest

@MainActor
final class SettingsFeatureTests: XCTestCase {
    func testInitialStateSetupIsCorrect() async throws {
        let buildNumber: String = UUID().uuidString
        let versionNumber: String = UUID().uuidString
        let showRunDetail: Bool = .random()
        let showHistory: Bool = .random()

        let store = TestStore(
            initialState: .init(),
            reducer: SettingsFeature.init,
            withDependencies: {
                $0.bundleInfo = .init(
                    bundleIdentifier: UUID().uuidString,
                    name: UUID().uuidString,
                    displayName: UUID().uuidString,
                    spokenName: UUID().uuidString,
                    shortVersion: versionNumber,
                    version: buildNumber
                )

                $0.defaultAppStorage.set(showRunDetail, forKey: "show_run_detail")
                $0.defaultAppStorage.set(showHistory, forKey: "history_feature")
            }
        )

        await store.send(.view(.onAppear)) {
            $0.versionNumber = versionNumber
            $0.buildNumber = buildNumber
            $0.showRunDetailFeatureFlag = showRunDetail
            $0.showHistoryFeatureFlag = showHistory
        }
    }
}
