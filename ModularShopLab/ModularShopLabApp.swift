import Observability
import SwiftUI

@main
struct ModularShopLabApp: App {
    @State private var dependencies = AppDependencies()

    init() {
        FirebaseObservability.configureIfAvailable()
    }

    var body: some Scene {
        WindowGroup {
            AppRootView(dependencies: dependencies)
        }
    }
}
