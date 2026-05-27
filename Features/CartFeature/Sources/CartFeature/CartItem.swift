import Foundation
import ProductCatalog

public struct CartItem: Identifiable, Equatable, Sendable {
    public let id: Int
    public let product: Product
    public let quantity: Int

    public init(product: Product, quantity: Int) {
        self.id = product.id
        self.product = product
        self.quantity = quantity
    }

    public var subtotal: Double {
        product.price * Double(quantity)
    }
}
