import DesignSystem
import ProductCatalog
import SwiftUI

public struct ProductListView: View {
    @State private var viewModel: ProductListViewModel
    private let onAddToCart: (@MainActor @Sendable (Product) -> Void)?
    private let onStartSale: (@MainActor @Sendable (Product) -> Void)?
    private let selectedClientName: String?
    private let onSelectClient: (@MainActor @Sendable () -> Void)?
    private let allowsSearch: Bool
    private let allowsFavorites: Bool
    private let isFavorite: @MainActor (Product) -> Bool
    private let onToggleFavorite: @MainActor (Product) -> Void

    public init(
        viewModel: ProductListViewModel,
        onAddToCart: (@MainActor @Sendable (Product) -> Void)? = nil,
        onStartSale: (@MainActor @Sendable (Product) -> Void)? = nil,
        selectedClientName: String? = nil,
        onSelectClient: (@MainActor @Sendable () -> Void)? = nil,
        allowsSearch: Bool = true,
        allowsFavorites: Bool = true,
        isFavorite: @escaping @MainActor (Product) -> Bool = { _ in false },
        onToggleFavorite: @escaping @MainActor (Product) -> Void = { _ in }
    ) {
        _viewModel = State(initialValue: viewModel)
        self.onAddToCart = onAddToCart
        self.onStartSale = onStartSale
        self.selectedClientName = selectedClientName
        self.onSelectClient = onSelectClient
        self.allowsSearch = allowsSearch
        self.allowsFavorites = allowsFavorites
        self.isFavorite = isFavorite
        self.onToggleFavorite = onToggleFavorite
    }

    public var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading && viewModel.products.isEmpty {
                    LoadingView(L10n.string("products.loading"))
                } else if let errorMessage = viewModel.errorMessage, viewModel.products.isEmpty {
                    ErrorStateView(message: errorMessage) {
                        Task {
                            await viewModel.loadProducts()
                        }
                    }
                } else {
                    List(viewModel.products) { product in
                        NavigationLink {
                            ProductDetailView(
                                product: product,
                                selectedClientName: selectedClientName,
                                onStartSale: onStartSale,
                                onSelectClient: onSelectClient,
                                allowsFavorites: allowsFavorites,
                                isFavorite: isFavorite,
                                onToggleFavorite: onToggleFavorite
                            )
                        } label: {
                            ProductCardView(
                                imageURL: product.thumbnailURL,
                                title: product.title,
                                price: product.price.formatted(.currency(code: "USD")),
                                description: product.description,
                                actionTitle: onAddToCart == nil ? nil : L10n.string("products.add"),
                                action: addAction(for: product)
                            )
                            .swipeActions(edge: .leading) {
                                if allowsFavorites {
                                    Button {
                                        onToggleFavorite(product)
                                    } label: {
                                        Label(
                                            isFavorite(product) ? L10n.string("products.removeFavorite") : L10n.string("products.favorite"),
                                            systemImage: isFavorite(product) ? "heart.slash" : "heart"
                                        )
                                    }
                                    .tint(isFavorite(product) ? .gray : .pink)
                                }
                            }
                        }
                    }
                    .refreshable {
                        await viewModel.refresh()
                    }
                }
            }
            .navigationTitle(L10n.string("products.navigationTitle"))
        }
        .modifier(
            ProductSearchModifier(
                isEnabled: allowsSearch,
                searchQuery: $viewModel.searchQuery,
                onSearch: {
                    Task {
                        await viewModel.search()
                    }
                }
            )
        )
        .task {
            if viewModel.products.isEmpty {
                await viewModel.loadProducts()
            }
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

private struct ProductSearchModifier: ViewModifier {
    let isEnabled: Bool
    @Binding var searchQuery: String
    let onSearch: @MainActor () -> Void

    @ViewBuilder
    func body(content: Content) -> some View {
        if isEnabled {
            content
                .searchable(text: $searchQuery, prompt: Text(L10n.string("products.searchPrompt")))
                .onSubmit(of: .search, onSearch)
                .onChange(of: searchQuery) { _, newValue in
                    if newValue.isEmpty {
                        onSearch()
                    }
                }
        } else {
            content
        }
    }
}
