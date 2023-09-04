import App
import ComposableArchitecture
import SwiftUI

@main
struct RunningApp: App {
    let store: StoreOf<AppFeature> = .init(
        initialState: .init(),
        reducer: AppFeature.init,
        withDependencies: {
            $0 = .preview
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
