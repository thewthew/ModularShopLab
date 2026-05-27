import Foundation
import Observation

public enum ClientFlowRoute: Hashable, Sendable {
    case detail(Client)
    case create
    case update(Client)
}

@MainActor
@Observable
public final class ClientFlowCoordinator: Identifiable {
    public let id = UUID()
    public var path: [ClientFlowRoute] = []

    public let searchViewModel: ClientSearchViewModel
    private let dependencies: ClientFeatureDependencies

    public init(dependencies: ClientFeatureDependencies) {
        self.dependencies = dependencies
        self.searchViewModel = dependencies.makeSearchViewModel()
    }

    public convenience init(repository: any ClientRepository) {
        self.init(dependencies: ClientFeatureDependencies(repository: repository))
    }

    public func showCreate() {
        path.append(.create)
    }

    public func showDetail(for client: Client) {
        path.append(.detail(client))
    }

    public func showUpdate(for client: Client) {
        path.append(.update(client))
    }

    public func makeCreateViewModel() -> ClientFormViewModel {
        dependencies.makeCreateFormViewModel()
    }

    public func makeUpdateViewModel(for client: Client) -> ClientFormViewModel {
        dependencies.makeUpdateFormViewModel(for: client)
    }

    public func reloadRecentClients() {
        searchViewModel.loadRecentClients()
    }

    public func cancel() {
        searchViewModel.cancel()
    }

}
