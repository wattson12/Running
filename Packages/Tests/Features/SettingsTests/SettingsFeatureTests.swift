import ComposableArchitecture
import DependenciesAdditions
import FeatureFlags
@testable import Settings
import Testing
import Foundation

@MainActor
@Suite
struct SettingsFeatureTests {
    @Test func initialStateSetupIsCorrect() async throws {
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
            $0.$runDetailEnabled.withLock { $0 = showRunDetail }
        }
    }

    @Test func displayFeatureFlagIsCorrectForTestflightAndPreviewEnvironmentValues() throws {
        let inputs: [(String?, String?, Bool, SourceLocation)] = [
            (nil, nil, false, #_sourceLocation),
            (nil, "1", true, #_sourceLocation),
            ("YES", nil, true, #_sourceLocation),
            ("YES", "1", true, #_sourceLocation),
            ("NO", nil, false, #_sourceLocation),
            (UUID().uuidString, nil, false, #_sourceLocation),
        ]

        for (testflight, preview, expected, sourceLocation) in inputs {
            let environment: [String: String?] = [
                "XCODE_RUNNING_FOR_PREVIEWS": preview,
            ]
            let bundleInfo: [String: Any]? = [
                "IS_TESTFLIGHT_BUILD": testflight as Any,
            ]
            let sut: SettingsFeature.State = .init()
            let displayFeatureFlags = withDependencies {
                $0.processInfo.$environment = environment.compactMapValues { $0 }
            } operation: {
                sut._displayFeatureFlags(bundleInfo: bundleInfo)
            }
            #expect(displayFeatureFlags == expected, sourceLocation: sourceLocation)
        }
    }
}
