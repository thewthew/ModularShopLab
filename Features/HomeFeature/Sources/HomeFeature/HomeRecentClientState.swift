public struct HomeRecentClientState: Identifiable, Equatable, Sendable {
    public let id: Int
    public let displayName: String
    public let email: String

    public init(id: Int, displayName: String, email: String) {
        self.id = id
        self.displayName = displayName
        self.email = email
    }
}
