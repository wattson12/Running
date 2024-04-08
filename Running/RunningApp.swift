import App
import ComposableArchitecture
import Logging
import SwiftUI

@main
struct RunningApp: App {
    let store: StoreOf<AppFeature> = .init(
        initialState: .init(),
        reducer: { AppFeature()._logging() },
        withDependencies: {
            #if targetEnvironment(simulator)
                $0 = .preview
                $0.date = .constant(.preview)
                $0.updateForScreenshots()
                $0.defaultAppStorage = .standard
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
                .init(period: .weekly, target: .init(value: 30, unit: locale.primaryUnit)),
                .init(period: .monthly, target: nil),
                .init(period: .yearly, target: .init(value: 250, unit: locale.primaryUnit)),
            ]
        )
        self.locale = locale
    }
}
