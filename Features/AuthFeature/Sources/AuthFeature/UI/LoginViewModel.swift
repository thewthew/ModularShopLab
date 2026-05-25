import Observation

@MainActor
@Observable
public final class LoginViewModel {
    public var username = "emilys"
    public var password = "emilyspass"
    public private(set) var isLoading = false
    public private(set) var errorMessage: String?

    private let repository: any AuthRepository

    public init(repository: any AuthRepository) {
        self.repository = repository
    }

    public func login() async -> UserSession? {
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
            return try await repository.login(
                credentials: LoginCredentials(username: username, password: password)
            )
        } catch {
            errorMessage = L10n.string("auth.error.loginFailed")
            return nil
        }
    }
}
