import FeatureFlags
import SwiftUI

enum AppExperience: Sendable {
    case iPhone
    case iPad

    var platform: AppPlatform {
        switch self {
        case .iPhone:
            .iPhone
        case .iPad:
            .iPad
        }
    }

    @MainActor
    static var current: AppExperience {
        #if os(iOS)
        UIDevice.current.userInterfaceIdiom == .pad ? .iPad : .iPhone
        #else
        .iPhone
        #endif
    }
}
