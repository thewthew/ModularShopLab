import ProductCatalog
import Testing
@testable import ProductFeature

@MainActor
@Test
func productListViewModelLoadsProductsSuccessfully() async {
    let products = [
        Product(id: 1, title: "Phone", price: 799, description: "A phone", thumbnailURL: nil)
    ]
    let viewModel = ProductListViewModel(repository: StubProductRepository(result: .success(products)))

    await viewModel.loadProducts()

    #expect(viewModel.products == products)
    #expect(viewModel.errorMessage == nil)
    #expect(viewModel.isLoading == false)
}

@MainActor
@Test
func productListViewModelHandlesError() async {
    let viewModel = ProductListViewModel(repository: StubProductRepository(result: .failure(TestError.failure)))

    await viewModel.loadProducts()

    #expect(viewModel.products.isEmpty)
    #expect(viewModel.errorMessage == "Unable to load products.")
    #expect(viewModel.isLoading == false)
}

@MainActor
@Test
func productListViewModelSearchesProducts() async {
    let products = [
        Product(id: 2, title: "Laptop", price: 1_299, description: "A laptop", thumbnailURL: nil)
    ]
    let repository = StubProductRepository(result: .success([]), searchResult: .success(products))
    let viewModel = ProductListViewModel(repository: repository)

    viewModel.searchQuery = "laptop"
    await viewModel.search()

    #expect(viewModel.products == products)
    #expect(viewModel.errorMessage == nil)
}

private struct StubProductRepository: ProductRepository {
    let result: Result<[Product], Error>
    var searchResult: Result<[Product], Error>?

    func products() async throws -> [Product] {
        try result.get()
    }

    func searchProducts(query: String) async throws -> [Product] {
        try (searchResult ?? result).get()
    }
}

private enum TestError: Error {
    case failure
}
