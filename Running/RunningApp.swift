import App
import ComposableArchitecture
import SwiftUI

@main
struct RunningApp: App {
    let store: StoreOf<AppFeature> = .init(
        initialState: .init(),
        reducer: AppFeature.init,
        withDependencies: {
#if targetEnvironment(simulator)
            $0 = .preview
            $0.date = .constant(.preview)
            $0.locale = .init(identifier: "en_AU")
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
                .environment(\.locale, .init(identifier: "en_AU"))
        }
    }
}
