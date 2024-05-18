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

    func testDisplayFeatureFlagIsCorrectForTestflightAndPreviewEnvironmentValues() throws {
        let inputs: [(String?, String?, Bool, UInt)] = [
            (nil, nil, false, #line),
            (nil, "1", true, #line),
            ("1", nil, true, #line),
            ("1", "1", true, #line),
        ]

        for (testflight, preview, expected, line) in inputs {
            let environment: [String: String?] = [
                "ENV_TESTFLIGHT": testflight,
                "XCODE_RUNNING_FOR_PREVIEWS": preview,
            ]
            let sut: SettingsFeature.State = .init()
            let displayFeatureFlags = withDependencies {
                $0.processInfo.$environment = environment.compactMapValues { $0 }
            } operation: {
                sut.displayFeatureFlags
            }
            XCTAssertEqual(displayFeatureFlags, expected, line: line)
        }
    }
}
