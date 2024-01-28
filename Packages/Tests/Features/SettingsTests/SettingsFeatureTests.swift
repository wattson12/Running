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
                $0.userDefaults = .ephemeral()
                $0.featureFlags._get = { key in
                    if key == .showRunDetail {
                        return showRunDetail
                    } else if key == .history {
                        return showHistory
                    } else {
                        XCTFail()
                        return .random()
                    }
                }
            }
        )

        await store.send(.view(.onAppear)) {
            $0.versionNumber = versionNumber
            $0.buildNumber = buildNumber
            $0.showRunDetailFeatureFlag = showRunDetail
            $0.showHistoryFeatureFlag = showHistory
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

        await store.send(.binding(.set(\.showRunDetailFeatureFlag, true)))

        await store.receive(.delegate(.featureFlagsUpdated))

        XCTAssertEqual(lastSetValue.value, true)

        await store.send(.binding(.set(\.showRunDetailFeatureFlag, false)))

        await store.receive(.delegate(.featureFlagsUpdated))

        XCTAssertEqual(lastSetValue.value, false)
    }

    func testBindingForShowHistoryUpdatesFeatureFlags() async throws {
        let lastSetValue: LockIsolated<Bool?> = .init(nil)

        let store = TestStore(
            initialState: .init(),
            reducer: SettingsFeature.init,
            withDependencies: {
                $0.featureFlags._set = { key, value in
                    XCTAssertEqual(key, .history)
                    lastSetValue.setValue(value)
                }
            }
        )

        store.exhaustivity = .off

        await store.send(.binding(.set(\.showHistoryFeatureFlag, true)))

        await store.receive(.delegate(.featureFlagsUpdated))

        XCTAssertEqual(lastSetValue.value, true)

        await store.send(.binding(.set(\.showHistoryFeatureFlag, false)))

        await store.receive(.delegate(.featureFlagsUpdated))

        XCTAssertEqual(lastSetValue.value, false)
    }
}
