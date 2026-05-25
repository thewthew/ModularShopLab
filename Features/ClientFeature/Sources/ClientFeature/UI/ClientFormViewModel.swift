import Observation

@MainActor
@Observable
public final class ClientFormViewModel {
    public enum Mode: Equatable, Sendable {
        case create
        case update(Client)
    }

    public let mode: Mode
    public var firstName: String
    public var lastName: String
    public var email: String
    public var phone: String
    public var country: ClientCountry

    public private(set) var isLoading = false
    public private(set) var errorMessage: String?

    private let saveClientUseCase: SaveClientUseCase

    public init(mode: Mode, saveClientUseCase: SaveClientUseCase) {
        self.mode = mode
        self.saveClientUseCase = saveClientUseCase

        switch mode {
        case .create:
            self.firstName = ""
            self.lastName = ""
            self.email = ""
            self.phone = ""
            self.country = .france
        case let .update(client):
            self.firstName = client.firstName
            self.lastName = client.lastName
            self.email = client.email
            self.phone = client.phone ?? ""
            self.country = client.country
        }
    }

    public var title: String {
        switch mode {
        case .create:
            L10n.string("client.createClient")
        case .update:
            L10n.string("client.updateClient")
        }
    }

    public var submitTitle: String {
        switch mode {
        case .create:
            L10n.string("client.create")
        case .update:
            L10n.string("client.save")
        }
    }

    public func save() async -> Client? {
        isLoading = true
        errorMessage = nil

        defer {
            isLoading = false
        }

        do {
            return try await saveClientUseCase.execute(
                mode: saveClientMode,
                input: ClientFormInput(
                    firstName: firstName,
                    lastName: lastName,
                    email: email,
                    phone: phone,
                    country: country
                )
            )
        } catch ClientError.emptyRequiredFields {
            errorMessage = L10n.string("client.error.requiredFields")
            return nil
        } catch {
            errorMessage = L10n.string("client.error.saveFailed")
            return nil
        }
    }

    private var saveClientMode: SaveClientMode {
        switch mode {
        case .create:
            .create
        case let .update(client):
            .update(client)
        }
    }
}
