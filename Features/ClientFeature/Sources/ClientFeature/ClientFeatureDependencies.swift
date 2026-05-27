public struct ClientFeatureDependencies: Sendable {
    private let repository: any ClientRepository
    private let saveClientUseCase: SaveClientUseCase

    public init(repository: any ClientRepository) {
        self.repository = repository
        self.saveClientUseCase = SaveClientUseCase(repository: repository)
    }

    @MainActor
    public func makeSearchViewModel() -> ClientSearchViewModel {
        ClientSearchViewModel(repository: repository)
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
