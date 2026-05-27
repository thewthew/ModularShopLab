/// Stores clients recently seen by the seller.
///
/// This is a local convenience cache, not the source of truth for client data.
public protocol RecentClientStore: Sendable {
    @MainActor
    func recentClients(limit: Int) throws -> [Client]

    @MainActor
    func record(_ client: Client) throws

    @MainActor
    func record(_ clients: [Client]) throws
}

/// Null implementation used by tests, previews or fallback app startup.
public final class NoRecentClientStore: RecentClientStore {
    public init() {}

    @MainActor
    public func recentClients(limit: Int) throws -> [Client] {
        []
    }

    @MainActor
    public func record(_ client: Client) throws {}

    @MainActor
    public func record(_ clients: [Client]) throws {}
}
