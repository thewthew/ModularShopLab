import ClientFeature
import SwiftData
import Testing

@MainActor
@Test
func swiftDataRecentClientStoreReturnsMostRecentClientsFirst() throws {
    let container = try ModelContainer(
        for: RecentClientRecord.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    let store = SwiftDataRecentClientStore(modelContext: ModelContext(container))

    let firstClient = Client(id: 1, firstName: "Camille", lastName: "Martin", email: "camille@example.com")
    let secondClient = Client(id: 2, firstName: "Alex", lastName: "Taylor", email: "alex@example.com")

    try store.record(firstClient)
    try store.record(secondClient)

    let recentClients = try store.recentClients(limit: 2)

    #expect(recentClients == [secondClient, firstClient])
}

@MainActor
@Test
func swiftDataRecentClientStoreUpsertsExistingClient() throws {
    let container = try ModelContainer(
        for: RecentClientRecord.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    let store = SwiftDataRecentClientStore(modelContext: ModelContext(container))

    try store.record(Client(id: 1, firstName: "Camille", lastName: "Martin", email: "old@example.com"))
    let updatedClient = Client(id: 1, firstName: "Camille", lastName: "Moreau", email: "new@example.com")
    try store.record(updatedClient)

    let recentClients = try store.recentClients(limit: 10)

    #expect(recentClients == [updatedClient])
}
