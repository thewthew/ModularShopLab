import Foundation
import SwiftData

@Model
public final class RecentClientRecord {
    @Attribute(.unique) public var clientID: Int
    public var firstName: String
    public var lastName: String
    public var email: String
    public var phone: String?
    public var countryRawValue: String
    public var lastSeenAt: Date

    public init(client: Client, lastSeenAt: Date = .now) {
        self.clientID = client.id
        self.firstName = client.firstName
        self.lastName = client.lastName
        self.email = client.email
        self.phone = client.phone
        self.countryRawValue = client.country.rawValue
        self.lastSeenAt = lastSeenAt
    }

    public func update(with client: Client, lastSeenAt: Date = .now) {
        firstName = client.firstName
        lastName = client.lastName
        email = client.email
        phone = client.phone
        countryRawValue = client.country.rawValue
        self.lastSeenAt = lastSeenAt
    }

    public var client: Client {
        Client(
            id: clientID,
            firstName: firstName,
            lastName: lastName,
            email: email,
            phone: phone,
            country: ClientCountry(rawValue: countryRawValue) ?? .france
        )
    }
}
