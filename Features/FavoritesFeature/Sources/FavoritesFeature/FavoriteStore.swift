import ProductCatalog

public protocol FavoriteStore: Sendable {
    func products() async -> [Product]
    func contains(productID: Product.ID) async -> Bool
    func toggle(product: Product) async
}

public actor InMemoryFavoriteStore: FavoriteStore {
    private var favorites: [Product.ID: Product] = [:]

    public init() {}

    public func products() async -> [Product] {
        favorites.values.sorted { $0.title < $1.title }
    }

    public func contains(productID: Product.ID) async -> Bool {
        favorites[productID] != nil
    }

    public func toggle(product: Product) async {
        if favorites[product.id] == nil {
            favorites[product.id] = product
        } else {
            favorites[product.id] = nil
        }
    }
}
