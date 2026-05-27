import Foundation

/// Shared product search rule used by both selling and showroom experiences.
///
/// A blank query intentionally falls back to the full product catalog so each UI
/// can decide how search is presented without duplicating catalog semantics.
public struct SearchProductsUseCase: Sendable {
    private let repository: any ProductRepository

    public init(repository: any ProductRepository) {
        self.repository = repository
    }

    public func execute(query: String) async throws -> [Product] {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else {
            return try await repository.products()
        }

        return try await repository.searchProducts(query: trimmedQuery)
    }
}
