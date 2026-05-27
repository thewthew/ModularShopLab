import ProductCatalog
import Testing
@testable import FavoritesFeature

@MainActor
@Test
func favoritesViewModelTogglesProducts() async {
    let store = InMemoryFavoriteStore()
    let viewModel = FavoritesViewModel(store: store)
    let product = Product(id: 1, title: "Phone", price: 799, description: "A phone", thumbnailURL: nil)

    await viewModel.toggle(product: product)

    #expect(viewModel.products == [product])
    #expect(viewModel.isFavorite(product: product))

    await viewModel.toggle(product: product)

    #expect(viewModel.products.isEmpty)
    #expect(!viewModel.isFavorite(product: product))
}
