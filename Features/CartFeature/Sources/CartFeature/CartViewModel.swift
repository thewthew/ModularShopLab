import Observation
import ProductCatalog

@MainActor
@Observable
public final class CartViewModel {
    public private(set) var items: [CartItem] = []

    private let store: any CartStore

    public init(store: any CartStore) {
        self.store = store
    }

    public var total: Double {
        items.reduce(0) { $0 + $1.subtotal }
    }

    public func loadCart() async {
        items = await store.items()
    }

    public func add(product: Product) async {
        await store.add(product: product)
        await loadCart()
    }

    public func remove(productID: Product.ID) async {
        await store.remove(productID: productID)
        await loadCart()
    }
}
