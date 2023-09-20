import ComposableArchitecture
import DependenciesAdditions
@testable import Settings
import XCTest

@MainActor
final class SettingsFeatureTests: XCTestCase {
    func testInitialStateSetupIsCorrect() async throws {
        let buildNumber: String = UUID().uuidString
        let versionNumber: String = UUID().uuidString

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
                $0.userDefaults = .ephemeral()
            }
        )

        await store.send(.view(.onAppear)) {
            $0.versionNumber = versionNumber
            $0.buildNumber = buildNumber
        }
    }

    func testHiddenAreaGestureFiredTogglesState() async throws {
        let store = TestStore(
            initialState: .init(debugSectionVisible: false),
            reducer: SettingsFeature.init
        )

        await store.send(.view(.hiddenAreaGestureFired)) {
            $0.debugSectionVisible = true
        }

        await store.send(.view(.hiddenAreaGestureFired)) {
            $0.debugSectionVisible = false
        }
    }
}
