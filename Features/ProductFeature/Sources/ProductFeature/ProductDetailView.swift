import DesignSystem
import SwiftUI

public struct ProductDetailView: View {
    private let product: Product
    private let selectedClientName: String?
    private let onStartSale: (@MainActor @Sendable (Product) -> Void)?
    private let onSelectClient: (@MainActor @Sendable () -> Void)?
    private let allowsFavorites: Bool
    private let isFavorite: @MainActor (Product) -> Bool
    private let onToggleFavorite: @MainActor (Product) -> Void

    public init(
        product: Product,
        selectedClientName: String? = nil,
        onStartSale: (@MainActor @Sendable (Product) -> Void)? = nil,
        onSelectClient: (@MainActor @Sendable () -> Void)? = nil,
        allowsFavorites: Bool = true,
        isFavorite: @escaping @MainActor (Product) -> Bool = { _ in false },
        onToggleFavorite: @escaping @MainActor (Product) -> Void = { _ in }
    ) {
        self.product = product
        self.selectedClientName = selectedClientName
        self.onStartSale = onStartSale
        self.onSelectClient = onSelectClient
        self.allowsFavorites = allowsFavorites
        self.isFavorite = isFavorite
        self.onToggleFavorite = onToggleFavorite
    }

    public var body: some View {
        List {
            Section {
                AsyncImage(url: product.thumbnailURL) { image in
                    image
                        .resizable()
                        .scaledToFit()
                } placeholder: {
                    Rectangle()
                        .fill(ShopColors.surface)
                        .overlay {
                            Image(systemName: "photo")
                                .foregroundStyle(.secondary)
                        }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 240)
                .clipShape(RoundedRectangle(cornerRadius: 8))

                VStack(alignment: .leading, spacing: ShopSpacing.small) {
                    HStack(alignment: .firstTextBaseline) {
                        Text(product.title)
                            .font(.title2.weight(.semibold))
                        Spacer()
                        Text(product.price.formatted(.currency(code: "USD")))
                            .font(.headline)
                    }

                    Text(product.description)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, ShopSpacing.small)
            }

            if onStartSale != nil || onSelectClient != nil {
                Section(L10n.string("products.sale")) {
                    if let selectedClientName {
                        Label(selectedClientName, systemImage: "person.fill")
                    } else {
                        Label(L10n.string("products.noClientSelected"), systemImage: "person")
                            .foregroundStyle(.secondary)
                    }

                    if let onSelectClient {
                        Button {
                            onSelectClient()
                        } label: {
                            Label(L10n.string("products.selectOrCreateClient"), systemImage: "person.badge.plus")
                        }
                    }

                    if let onStartSale {
                        Button {
                            onStartSale(product)
                        } label: {
                            Label(L10n.string("products.startSale"), systemImage: "cart.badge.plus")
                        }
                    }
                }
            }

            if allowsFavorites {
                Section {
                    Button {
                        onToggleFavorite(product)
                    } label: {
                        Label(
                            isFavorite(product) ? L10n.string("products.removeFavorite") : L10n.string("products.addFavorite"),
                            systemImage: isFavorite(product) ? "heart.slash" : "heart"
                        )
                    }
                }
            }
        }
        .navigationTitle(L10n.string("products.detailNavigationTitle"))
    }
}
