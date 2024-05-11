import ComposableArchitecture
import DependenciesAdditions
import FeatureFlags
@testable import Settings
import XCTest

final class SettingsFeatureTests: XCTestCase {
    @MainActor
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

                $0.defaultAppStorage.set(showRunDetail, forKey: FeatureFlagKey.runDetail.name)
                $0.defaultAppStorage.set(showHistory, forKey: FeatureFlagKey.history.name)
            }
        )

        await store.send(.view(.onAppear)) {
            $0.versionNumber = versionNumber
            $0.buildNumber = buildNumber
            $0.runDetailEnabled = showRunDetail
            $0.historyEnabled = showHistory
        }
    }
}
