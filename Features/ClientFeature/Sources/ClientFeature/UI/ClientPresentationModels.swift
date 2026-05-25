public struct ClientRowState: Identifiable, Equatable, Sendable {
    public let id: Client.ID
    public let displayName: String
    public let email: String
    public let countryName: String

    public init(client: Client) {
        self.id = client.id
        self.displayName = client.displayName
        self.email = client.email
        self.countryName = client.country.localizedName
    }
}

public struct ClientDetailViewState: Equatable, Sendable {
    public let title: String
    public let displayName: String
    public let email: String
    public let phone: String?
    public let countryName: String

    public init(client: Client) {
        self.title = client.displayName
        self.displayName = client.displayName
        self.email = client.email
        self.phone = client.phone
        self.countryName = client.country.localizedName
    }
}

extension ClientCountry {
    var localizedName: String {
        switch self {
        case .france:
            L10n.string("client.country.france")
        case .belgium:
            L10n.string("client.country.belgium")
        case .germany:
            L10n.string("client.country.germany")
        case .italy:
            L10n.string("client.country.italy")
        case .spain:
            L10n.string("client.country.spain")
        case .unitedKingdom:
            L10n.string("client.country.unitedKingdom")
        case .unitedStates:
            L10n.string("client.country.unitedStates")
        }
    }
}
