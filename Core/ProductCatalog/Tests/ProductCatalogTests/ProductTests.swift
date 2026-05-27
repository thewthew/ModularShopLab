import Foundation
import Testing

@testable import ProductCatalog

@Test
func productIsEquatableAndSendable() {
    let product = Product(
        id: 1,
        title: "Phone",
        price: 799,
        description: "A phone",
        thumbnailURL: URL(string: "https://example.com/phone.png")
    )

    #expect(product == product)
}
