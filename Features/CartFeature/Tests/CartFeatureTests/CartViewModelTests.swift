import ProductCatalog
import Testing
@testable import CartFeature

@MainActor
@Test
func cartViewModelAddsProductsAndCalculatesTotal() async {
    let store = InMemoryCartStore()
    let viewModel = CartViewModel(store: store)
    let phone = Product(id: 1, title: "Phone", price: 799, description: "A phone", thumbnailURL: nil)
    let caseProduct = Product(id: 2, title: "Case", price: 29, description: "A case", thumbnailURL: nil)

    await viewModel.add(product: phone)
    await viewModel.add(product: phone)
    await viewModel.add(product: caseProduct)

    #expect(viewModel.items.count == 2)
    #expect(viewModel.items.first { $0.product.id == phone.id }?.quantity == 2)
    #expect(viewModel.total == 1_627)
}
