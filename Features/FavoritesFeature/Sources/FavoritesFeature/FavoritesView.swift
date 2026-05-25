import DesignSystem
import ProductFeature
import SwiftUI

public struct FavoritesView: View {
    @State private var viewModel: FavoritesViewModel
    private let onAddToCart: (@MainActor @Sendable (Product) -> Void)?

    public init(
        viewModel: FavoritesViewModel,
        onAddToCart: (@MainActor @Sendable (Product) -> Void)? = nil
    ) {
        _viewModel = State(initialValue: viewModel)
        self.onAddToCart = onAddToCart
    }

    public var body: some View {
        NavigationStack {
            Group {
                if viewModel.products.isEmpty {
                    ContentUnavailableView(
                        L10n.string("favorites.emptyTitle"),
                        systemImage: "heart",
                        description: Text(L10n.string("favorites.emptyDescription"))
                    )
                } else {
                    List(viewModel.products) { product in
                        ProductCardView(
                            imageURL: product.thumbnailURL,
                            title: product.title,
                            price: product.price.formatted(.currency(code: "USD")),
                            description: product.description,
                            actionTitle: onAddToCart == nil ? nil : L10n.string("favorites.add"),
                            action: addAction(for: product)
                        )
                        .swipeActions {
                            Button(role: .destructive) {
                                Task {
                                    await viewModel.toggle(product: product)
                                }
                            } label: {
                                Label(L10n.string("favorites.remove"), systemImage: "heart.slash")
                            }
                        }
                    }
                }
            }
            .navigationTitle(L10n.string("favorites.navigationTitle"))
        }
        .task {
            await viewModel.loadFavorites()
        }
    }

    private func addAction(for product: Product) -> (@MainActor @Sendable () -> Void)? {
        guard let onAddToCart else {
            return nil
        }

        return { @MainActor @Sendable in
            onAddToCart(product)
        }
    }
}
