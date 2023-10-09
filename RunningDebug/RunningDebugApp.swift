import SwiftUI

@main
struct RunningDebugApp: App {
    var body: some Scene {
        WindowGroup {
            DebugAppView(
                store: .init(
                    initialState: .initial,
                    reducer: DebugAppFeature.init
                )
            )
        }
    }
}
