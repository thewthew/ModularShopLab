import Foundation

public struct Product: Identifiable, Equatable, Sendable {
    public let id: Int
    public let title: String
    public let price: Double
    public let description: String
    public let thumbnailURL: URL?

    public init(
        id: Int,
        title: String,
        price: Double,
        description: String,
        thumbnailURL: URL?
    ) {
        self.id = id
        self.title = title
        self.price = price
        self.description = description
        self.thumbnailURL = thumbnailURL
    }
}
