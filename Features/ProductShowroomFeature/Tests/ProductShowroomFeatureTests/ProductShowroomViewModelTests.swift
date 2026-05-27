import ProductCatalog
import ProductShowroomFeature
import Testing

@MainActor
@Test
func showroomLoadsProducts() async {
    let products = [
        Product(id: 1, title: "Jacket", price: 129, description: "Light jacket", thumbnailURL: nil)
    ]
    let viewModel = ProductShowroomViewModel(repository: StubProductRepository(result: .success(products)))

    await viewModel.loadProducts()

    #expect(viewModel.products == products)
    #expect(viewModel.errorMessage == nil)
}

@MainActor
@Test
func showroomHandlesLoadError() async {
    let viewModel = ProductShowroomViewModel(repository: StubProductRepository(result: .failure(TestError.failed)))

    await viewModel.loadProducts()

    #expect(viewModel.products.isEmpty)
    #expect(viewModel.errorMessage == "Unable to load showroom products.")
}

@MainActor
@Test
func showroomSearchesProductsWithSharedUseCase() async {
    let products = [
        Product(id: 2, title: "Trail Shoes", price: 159, description: "Trail shoes", thumbnailURL: nil)
    ]
    let repository = RecordingProductRepository(searchProducts: products)
    let viewModel = ProductShowroomViewModel(searchProductsUseCase: SearchProductsUseCase(repository: repository))

    viewModel.searchQuery = "  trail  "
    await viewModel.search()

    let lastSearchQuery = await repository.lastSearchQuery
    #expect(viewModel.products == products)
    #expect(lastSearchQuery == "trail")
}

@MainActor
@Test
func showroomTogglesSelectionAndComparisonState() {
    let first = Product(id: 1, title: "Jacket", price: 129, description: "Light jacket", thumbnailURL: nil)
    let second = Product(id: 2, title: "Shoes", price: 159, description: "Trail shoes", thumbnailURL: nil)
    let viewModel = ProductShowroomViewModel(repository: StubProductRepository(result: .success([])))

    viewModel.toggleSelection(for: first)
    viewModel.toggleSelection(for: second)

    #expect(viewModel.selectedProducts == [first, second])
    #expect(viewModel.canCompareSelection)

    viewModel.toggleSelection(for: first)

    #expect(viewModel.selectedProducts == [second])
    #expect(!viewModel.canCompareSelection)
}

private struct StubProductRepository: ProductRepository {
    let result: Result<[Product], Error>

    func products() async throws -> [Product] {
        try result.get()
    }

    func searchProducts(query: String) async throws -> [Product] {
        try result.get()
    }
}

private enum TestError: Error {
    case failed
}

private actor RecordingProductRepository: ProductRepository {
    private let searchedProducts: [Product]
    private(set) var lastSearchQuery: String?

    init(searchProducts: [Product]) {
        self.searchedProducts = searchProducts
    }

    func products() async throws -> [Product] {
        []
    }

    func searchProducts(query: String) async throws -> [Product] {
        lastSearchQuery = query
        return searchedProducts
    }
}
