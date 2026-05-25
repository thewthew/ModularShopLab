import Foundation
import Observation

@MainActor
@Observable
public final class ClientSearchViewModel {
    public var searchQuery = ""

    public private(set) var clients: [Client] = []
    public private(set) var clientRows: [ClientRowState] = []
    public private(set) var isLoading = false
    public private(set) var errorMessage: String?

    private let repository: any ClientRepository
    private var searchTask: Task<Void, Never>?

    public init(repository: any ClientRepository) {
        self.repository = repository
    }

    public func search() async {
        let trimmedQuery = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else {
            clients = []
            clientRows = []
            return
        }

        isLoading = true
        errorMessage = nil

        defer {
            isLoading = false
        }

        do {
            clients = try await repository.searchClients(query: trimmedQuery)
            clientRows = clients.map(ClientRowState.init)
        } catch {
            clients = []
            clientRows = []
            errorMessage = L10n.string("client.error.searchFailed")
        }
    }

    public func client(for row: ClientRowState) -> Client? {
        clients.first { $0.id == row.id }
    }

    public func searchDebounced() {
        searchTask?.cancel()

        searchTask = Task { [weak self] in
            do {
                try await Task.sleep(for: .milliseconds(250))
            } catch {
                return
            }

            guard let self, !Task.isCancelled else {
                return
            }

            await self.search()
        }
    }

    public func cancel() {
        searchTask?.cancel()
        searchTask = nil
    }

}
