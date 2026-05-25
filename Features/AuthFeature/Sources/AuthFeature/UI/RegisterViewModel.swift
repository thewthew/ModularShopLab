import Observation

@MainActor
@Observable
public final class RegisterViewModel {
    public var username = ""
    public var password = ""
    public private(set) var isLoading = false
    public private(set) var errorMessage: String?

    private let repository: any AuthRepository

    public init(repository: any AuthRepository) {
        self.repository = repository
    }

    public func register() async -> UserSession? {
        guard !username.isEmpty, !password.isEmpty else {
            errorMessage = L10n.string("auth.error.credentialsRequired")
            return nil
        }

        isLoading = true
        errorMessage = nil

        defer {
            isLoading = false
        }

        do {
            return try await repository.register(
                credentials: RegisterCredentials(username: username, password: password)
            )
        } catch {
            errorMessage = L10n.string("auth.error.accountCreationFailed")
            return nil
        }
    }
}
