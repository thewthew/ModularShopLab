public struct ClientFeatureDependencies: Sendable {
    private let repository: any ClientRepository
    private let recentClientStore: any RecentClientStore
    private let saveClientUseCase: SaveClientUseCase

    public init(
        repository: any ClientRepository,
        recentClientStore: any RecentClientStore = NoRecentClientStore()
    ) {
        self.repository = repository
        self.recentClientStore = recentClientStore
        self.saveClientUseCase = SaveClientUseCase(
            repository: repository,
            recentClientStore: recentClientStore
        )
    }

    @MainActor
    public func makeSearchViewModel() -> ClientSearchViewModel {
        ClientSearchViewModel(
            repository: repository,
            recentClientStore: recentClientStore
        )
    }

    @MainActor
    public func makeCreateFormViewModel() -> ClientFormViewModel {
        ClientFormViewModel(mode: .create, saveClientUseCase: saveClientUseCase)
    }

    @MainActor
    public func makeUpdateFormViewModel(for client: Client) -> ClientFormViewModel {
        ClientFormViewModel(mode: .update(client), saveClientUseCase: saveClientUseCase)
    }
}
