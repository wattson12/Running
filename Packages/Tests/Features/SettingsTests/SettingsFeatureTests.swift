import ComposableArchitecture
import DependenciesAdditions
@testable import Settings
import XCTest

@MainActor
final class SettingsFeatureTests: XCTestCase {
    func testInitialStateSetupIsCorrect() async throws {
        let buildNumber: String = UUID().uuidString
        let versionNumber: String = UUID().uuidString
        let debugTagVisible: Bool = .random()

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
                $0.userDefaults.set(debugTagVisible, forKey: "debug_tab_visible")
            }
        )

        await store.send(.view(.onAppear)) {
            $0.versionNumber = versionNumber
            $0.buildNumber = buildNumber
            $0.debugTabVisible = debugTagVisible
        }
    }

    func testHiddenAreaGestureFiredTogglesState() async throws {
        let store = TestStore(
            initialState: .init(),
            reducer: SettingsFeature.init
        )

        await store.send(.view(.hiddenAreaGestureFired)) {
            $0.debugSectionVisible = true
        }

        await store.send(.view(.hiddenAreaGestureFired)) {
            $0.debugSectionVisible = false
        }
    }

    func testTogglingDebugTabVisibilityUpdatesStateAndUserDefaultsAndSendsCorrectDelegate() async throws {
        let userDefaults: UserDefaults.Dependency = .ephemeral()

        let store = TestStore(
            initialState: .init(),
            reducer: SettingsFeature.init,
            withDependencies: {
                $0.userDefaults = userDefaults
            }
        )

        // enable
        await store.send(.view(.setDebugTabVisible(true))) {
            $0.debugTabVisible = true
        }

        await store.receive(.delegate(.setDebugTabVisibility(true)))

        XCTAssertEqual(userDefaults.bool(forKey: "debug_tab_visible"), true)

        // disable
        await store.send(.view(.setDebugTabVisible(false))) {
            $0.debugTabVisible = false
        }

        await store.receive(.delegate(.setDebugTabVisibility(false)))

        XCTAssertEqual(userDefaults.bool(forKey: "debug_tab_visible"), false)
    }
}
