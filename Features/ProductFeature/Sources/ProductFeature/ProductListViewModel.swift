import Foundation
import Observation

@MainActor
@Observable
public final class ProductListViewModel {
    public private(set) var products: [Product] = []
    public private(set) var isLoading = false
    public private(set) var errorMessage: String?
    public var searchQuery = ""

    private let repository: any ProductRepository

    public init(repository: any ProductRepository) {
        self.repository = repository
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
            if searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                products = try await repository.products()
            } else {
                products = try await repository.searchProducts(query: searchQuery)
            }
        } catch {
            products = []
            errorMessage = L10n.string("products.error.loadFailed")
        }
    }

    public func refresh() async {
        await loadProducts()
    }

    public func search() async {
        await loadProducts()
    }
}
