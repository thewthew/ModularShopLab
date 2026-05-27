import Foundation
import SwiftData

@MainActor
public final class SwiftDataRecentClientStore: RecentClientStore {
    // ModelContext is intentionally main-actor isolated in this sample.
    // For heavier persistence work, move this behind a dedicated model actor.
    private let modelContext: ModelContext

    public init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    public func recentClients(limit: Int = 5) throws -> [Client] {
        var descriptor = FetchDescriptor<RecentClientRecord>(
            sortBy: [SortDescriptor(\.lastSeenAt, order: .reverse)]
        )
        descriptor.fetchLimit = limit

        return try modelContext.fetch(descriptor).map(\.client)
    }

    public func record(_ client: Client) throws {
        let clientID = client.id
        let descriptor = FetchDescriptor<RecentClientRecord>(
            predicate: #Predicate { record in
                record.clientID == clientID
            }
        )

        if let existingRecord = try modelContext.fetch(descriptor).first {
            existingRecord.update(with: client)
        } else {
            modelContext.insert(RecentClientRecord(client: client))
        }

        try modelContext.save()
    }

    public func record(_ clients: [Client]) throws {
        for client in clients {
            try record(client)
        }
    }
}
