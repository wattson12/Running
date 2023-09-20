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
        }
    }
}
