import Foundation
import Observation
import ProductCatalog

@MainActor
@Observable
public final class ProductShowroomViewModel {
    public private(set) var products: [Product] = []
    public private(set) var selectedProducts: [Product] = []
    public private(set) var isLoading = false
    public private(set) var errorMessage: String?
    public var searchQuery = ""

    private let searchProductsUseCase: SearchProductsUseCase

    public init(searchProductsUseCase: SearchProductsUseCase) {
        self.searchProductsUseCase = searchProductsUseCase
    }

    public convenience init(repository: any ProductRepository) {
        self.init(searchProductsUseCase: SearchProductsUseCase(repository: repository))
    }

    public var canCompareSelection: Bool {
        selectedProducts.count >= 2
    }

    public func loadProducts() async {
        guard !isLoading else {
            return
        }

        isLoading = true
        errorMessage = nil

        defer {
            isLoading = false
        }

        do {
            products = try await searchProductsUseCase.execute(query: searchQuery)
        } catch {
            products = []
            errorMessage = L10n.string("showroom.error.loadFailed")
        }
    }

    public func refresh() async {
        await loadProducts()
    }

    public func search() async {
        await loadProducts()
    }

    public func toggleSelection(for product: Product) {
        if let index = selectedProducts.firstIndex(where: { $0.id == product.id }) {
            selectedProducts.remove(at: index)
        } else {
            selectedProducts.append(product)
        }
    }

    public func isSelected(_ product: Product) -> Bool {
        selectedProducts.contains { $0.id == product.id }
    }

    public func clearSelection() {
        selectedProducts = []
    }
}
