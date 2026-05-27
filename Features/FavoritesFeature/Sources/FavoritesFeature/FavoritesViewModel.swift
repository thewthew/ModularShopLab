import Observation
import ProductCatalog

@MainActor
@Observable
public final class FavoritesViewModel {
    public private(set) var products: [Product] = []
    private let store: any FavoriteStore

    public init(store: any FavoriteStore) {
        self.store = store
    }

    public func loadFavorites() async {
        products = await store.products()
    }

    public func isFavorite(product: Product) -> Bool {
        products.contains { $0.id == product.id }
    }

    public func toggle(product: Product) async {
        await store.toggle(product: product)
        await loadFavorites()
    }
}
