import ClientFeature
import Testing

@MainActor
@Test
func clientSearchViewModelSearchesClients() async {
    let client = Client(id: 1, firstName: "Sam", lastName: "Taylor", email: "sam@example.com", country: .france)
    let repository = StubClientRepository(searchResult: [client])
    let viewModel = ClientSearchViewModel(repository: repository)

    viewModel.searchQuery = "sam"
    await viewModel.search()

    #expect(viewModel.clients == [client])
    #expect(viewModel.errorMessage == nil)
}

@MainActor
@Test
func clientSearchViewModelRecordsSearchedClients() async {
    let client = Client(id: 4, firstName: "Maya", lastName: "Stone", email: "maya@example.com", country: .germany)
    let recentClientStore = SpyRecentClientStore()
    let viewModel = ClientSearchViewModel(
        repository: StubClientRepository(searchResult: [client]),
        recentClientStore: recentClientStore
    )

    viewModel.searchQuery = "maya"
    await viewModel.search()

    #expect(recentClientStore.recordedClients == [client])
    #expect(viewModel.recentClientRows == [ClientRowState(client: client)])
}

@MainActor
@Test
func clientSearchViewModelHandlesSearchError() async {
    let repository = StubClientRepository(searchError: TestError.failed)
    let viewModel = ClientSearchViewModel(repository: repository)

    viewModel.searchQuery = "sam"
    await viewModel.search()

    #expect(viewModel.clients.isEmpty)
    #expect(viewModel.errorMessage == "Unable to find clients.")
}

@MainActor
@Test
func clientFormViewModelCreatesClient() async {
    let client = Client(id: 2, firstName: "Alex", lastName: "Kim", email: "alex@example.com", country: .belgium)
    let repository = StubClientRepository(createdClient: client)
    let viewModel = ClientFormViewModel(mode: .create, saveClientUseCase: SaveClientUseCase(repository: repository))

    viewModel.firstName = "Alex"
    viewModel.lastName = "Kim"
    viewModel.email = "alex@example.com"
    viewModel.country = .belgium

    let createdClient = await viewModel.save()

    #expect(createdClient == client)
    #expect(viewModel.errorMessage == nil)
}

@MainActor
@Test
func clientFormViewModelRecordsCreatedClient() async {
    let client = Client(id: 5, firstName: "Lea", lastName: "Moreau", email: "lea@example.com", country: .france)
    let recentClientStore = SpyRecentClientStore()
    let viewModel = ClientFormViewModel(
        mode: .create,
        saveClientUseCase: SaveClientUseCase(
            repository: StubClientRepository(createdClient: client),
            recentClientStore: recentClientStore
        )
    )

    viewModel.firstName = "Lea"
    viewModel.lastName = "Moreau"
    viewModel.email = "lea@example.com"

    _ = await viewModel.save()

    #expect(recentClientStore.recordedClients == [client])
}

@MainActor
@Test
func clientFormViewModelUpdatesClient() async {
    let original = Client(id: 3, firstName: "Nina", lastName: "Lee", email: "nina@example.com", country: .france)
    let updated = Client(id: 3, firstName: "Nina", lastName: "Martin", email: "nina.martin@example.com", country: .spain)
    let repository = StubClientRepository(updatedClient: updated)
    let viewModel = ClientFormViewModel(mode: .update(original), saveClientUseCase: SaveClientUseCase(repository: repository))

    viewModel.lastName = "Martin"
    viewModel.email = "nina.martin@example.com"
    viewModel.country = .spain

    let savedClient = await viewModel.save()

    #expect(savedClient == updated)
    #expect(viewModel.errorMessage == nil)
}

private struct StubClientRepository: ClientRepository {
    var searchResult: [Client] = []
    var createdClient: Client?
    var updatedClient: Client?
    var searchError: (any Error)?

    func searchClients(query: String) async throws -> [Client] {
        if let searchError {
            throw searchError
        }
        return searchResult
    }

    func createClient(_ request: CreateClientRequest) async throws -> Client {
        if let createdClient {
            return createdClient
        }
        throw TestError.failed
    }

    func updateClient(_ request: UpdateClientRequest) async throws -> Client {
        if let updatedClient {
            return updatedClient
        }
        throw TestError.failed
    }
}

private enum TestError: Error {
    case failed
}

@MainActor
private final class SpyRecentClientStore: RecentClientStore {
    private(set) var recordedClients: [Client] = []

    func recentClients(limit: Int) throws -> [Client] {
        Array(recordedClients.suffix(limit).reversed())
    }

    func record(_ client: Client) throws {
        recordedClients.append(client)
    }

    func record(_ clients: [Client]) throws {
        recordedClients.append(contentsOf: clients)
    }
}
