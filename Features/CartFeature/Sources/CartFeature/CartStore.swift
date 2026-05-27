import ProductCatalog

public protocol CartStore: Sendable {
    func items() async -> [CartItem]
    func add(product: Product) async
    func remove(productID: Product.ID) async
}

public actor InMemoryCartStore: CartStore {
    private var cartItems: [Product.ID: CartItem] = [:]

    public init() {}

    public func items() async -> [CartItem] {
        cartItems.values.sorted { $0.product.title < $1.product.title }
    }

    public func add(product: Product) async {
        let currentQuantity = cartItems[product.id]?.quantity ?? 0
        cartItems[product.id] = CartItem(product: product, quantity: currentQuantity + 1)
    }

    public func remove(productID: Product.ID) async {
        cartItems[productID] = nil
    }
}
