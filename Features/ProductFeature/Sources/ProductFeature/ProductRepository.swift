import Foundation
import Networking
import ProductCatalog

public struct RemoteProductRepository: ProductRepository {
    private let apiClient: any APIClient

    public init(apiClient: any APIClient) {
        self.apiClient = apiClient
    }

    public func products() async throws -> [Product] {
        let response: ProductListResponseDTO = try await apiClient.send(
            APIRequest(path: "/products")
        )

        return response.products.map(\.domainModel)
    }

    public func searchProducts(query: String) async throws -> [Product] {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else {
            return try await products()
        }

        let response: ProductListResponseDTO = try await apiClient.send(
            APIRequest(
                path: "/products/search",
                queryItems: [URLQueryItem(name: "q", value: trimmedQuery)]
            )
        )

        return response.products.map(\.domainModel)
    }
}

private struct ProductListResponseDTO: Decodable, Sendable {
    let products: [ProductDTO]
}

private struct ProductDTO: Decodable, Sendable {
    let id: Int
    let title: String
    let price: Double
    let description: String
    let thumbnail: String

    var domainModel: Product {
        Product(
            id: id,
            title: title,
            price: price,
            description: description,
            thumbnailURL: URL(string: thumbnail)
        )
    }
}
