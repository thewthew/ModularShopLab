import Testing

@testable import ProductCatalog

@Test
func searchProductsUseCaseReturnsFullCatalogForBlankQuery() async throws {
    let products = [
        Product(id: 1, title: "Jacket", price: 129, description: "Light jacket", thumbnailURL: nil)
    ]
    let repository = StubProductRepository(products: products)
    let useCase = SearchProductsUseCase(repository: repository)

    let result = try await useCase.execute(query: "   ")

    #expect(result == products)
    let lastSearchQuery = await repository.lastSearchQuery
    #expect(lastSearchQuery == nil)
}

@Test
func searchProductsUseCaseTrimsAndSearchesNonBlankQuery() async throws {
    let products = [
        Product(id: 2, title: "Shoes", price: 159, description: "Trail shoes", thumbnailURL: nil)
    ]
    let repository = StubProductRepository(searchProducts: products)
    let useCase = SearchProductsUseCase(repository: repository)

    let result = try await useCase.execute(query: "  shoes  ")

    #expect(result == products)
    let lastSearchQuery = await repository.lastSearchQuery
    #expect(lastSearchQuery == "shoes")
}

private actor StubProductRepository: ProductRepository {
    private let catalogProducts: [Product]
    private let searchedProducts: [Product]
    private(set) var lastSearchQuery: String?

    init(products: [Product] = [], searchProducts: [Product] = []) {
        self.catalogProducts = products
        self.searchedProducts = searchProducts
    }

    func products() async throws -> [Product] {
        catalogProducts
    }

    func searchProducts(query: String) async throws -> [Product] {
        lastSearchQuery = query
        return searchedProducts
    }
}
