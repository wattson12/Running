import ComposableArchitecture
import DependenciesAdditions
import FeatureFlags
@testable import Settings
import XCTest

@MainActor
final class SettingsFeatureTests: XCTestCase {
    func testInitialStateSetupIsCorrect() async throws {
        let buildNumber: String = UUID().uuidString
        let versionNumber: String = UUID().uuidString
        let showRunDetail: Bool = .random()

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
                $0.featureFlags._get = { _ in showRunDetail }
            }
        )

        await store.send(.view(.onAppear)) {
            $0.versionNumber = versionNumber
            $0.buildNumber = buildNumber
            $0.showRunDetailFeatureFlag = showRunDetail
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

    func testBindingForShowRunDetailUpdatesFeatureFlags() async throws {
        let lastSetValue: LockIsolated<Bool?> = .init(nil)

        let store = TestStore(
            initialState: .init(),
            reducer: SettingsFeature.init,
            withDependencies: {
                $0.featureFlags._set = { key, value in
                    XCTAssertEqual(key, .showRunDetail)
                    lastSetValue.setValue(value)
                }
            }
        )

        store.exhaustivity = .off

        await store.send(.binding(.set(\.$showRunDetailFeatureFlag, true)))

        XCTAssertEqual(lastSetValue.value, true)

        await store.send(.binding(.set(\.$showRunDetailFeatureFlag, false)))

        XCTAssertEqual(lastSetValue.value, false)
    }
}
