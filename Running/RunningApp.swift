import App
import ComposableArchitecture
import SwiftUI

@main
struct RunningApp: App {
    let store: StoreOf<AppFeature> = .init(
        initialState: .init(),
        reducer: AppFeature.init,
        withDependencies: { dependencyValues in
            #if targetEnvironment(simulator)
                dependencyValues = .preview
                dependencyValues.date = .constant(.preview)
                // Make sure date is using preview value when creating screenshot mock data
                if ProcessInfo.processInfo.environment["SCREENSHOT_LOCALE"] != nil {
                    dependencyValues.date = .constant(.screenshots)
                    withDependencies {
                        $0.date = .constant(.screenshots)
                    } operation: {
                        dependencyValues.updateForScreenshots()
                    }
                }
                dependencyValues.defaultAppStorage = .standard
            #endif
        }
    )

    init() {
        UserDefaults.standard.set(false, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable")
    }

    var body: some Scene {
        WindowGroup {
            AppView(store: store)
                .onOpenURL { store.send(.deepLink($0)) }
                .localeForScreenshots()
        }
    }
}

private extension View {
    #if targetEnvironment(simulator)
        @ViewBuilder func localeForScreenshots() -> some View {
            if let screenshotLocale = ProcessInfo.processInfo.environment["SCREENSHOT_LOCALE"] {
                environment(\.locale, .init(identifier: screenshotLocale))
            } else {
                environment(\.locale, .init(identifier: "en_AU"))
            }
        }
    #else
        @ViewBuilder func localeForScreenshots() -> some View {
            self
        }
    #endif
}

private extension DependencyValues {
    mutating func updateForScreenshots() {
        guard let screenshotLocale = ProcessInfo.processInfo.environment["SCREENSHOT_LOCALE"] else { return }
        let locale = Locale(identifier: screenshotLocale)

        repository.runningWorkouts = .mock(
            runs: .screenshots(unit: locale.primaryUnit)
        )
        repository.goals = .mock(
            goals: [
                .init(period: .weekly, target: .init(value: 50, unit: locale.primaryUnit)),
                .init(period: .monthly, target: nil),
                .init(period: .yearly, target: .init(value: 1000, unit: locale.primaryUnit)),
            ]
        )
        self.locale = locale
    }
}
