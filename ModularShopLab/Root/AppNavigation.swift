import FeatureFlags

enum AppTab: Hashable {
    case home
    case products
    case favorites
    case clients
    case cart
}

enum AppSidebarItem: Hashable {
    case home
    case products
    case favorites
    case clients
}

extension AppExperience {
    var isIPad: Bool {
        if case .iPad = self {
            return true
        }

        return false
    }
}
