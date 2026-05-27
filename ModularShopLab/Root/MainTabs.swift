import CartFeature
import ClientFeature
import FavoritesFeature
import FeatureFlags
import HomeFeature
import ProductCatalog
import ProductFeature
import SwiftUI

struct MainTabs: View {
    let capabilities: AppCapabilities
    let sellerName: String
    let employeeRole: String
    let storeName: String
    let storeCode: String
    @Binding var selectedTab: AppTab
    let productListViewModel: ProductListViewModel
    let cartViewModel: CartViewModel
    let favoritesViewModel: FavoritesViewModel
    let clientTabCoordinator: ClientFlowCoordinator
    let selectedClientName: String?
    let recentClients: [HomeRecentClientState]
    let onClientSelected: @MainActor @Sendable (Client) -> Void
    let onRecentClientSelected: @MainActor @Sendable (HomeRecentClientState) -> Void
    let onRequestClientSelection: @MainActor @Sendable () -> Void
    let onOpenTips: @MainActor @Sendable () -> Void
    let onLogout: @MainActor @Sendable () -> Void
    let onCheckout: @MainActor @Sendable ([CartItem], Double) -> Void

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(
                sellerName: sellerName,
                employeeRole: employeeRole,
                storeName: storeName,
                storeCode: storeCode,
                selectedClientName: selectedClientName,
                recentClients: recentClients,
                canStartSale: capabilities.allows(.startSale),
                onStartSale: {
                    selectedTab = .products
                },
                onCreateClient: onRequestClientSelection,
                onRecentClientSelected: onRecentClientSelected,
                onOpenTips: onOpenTips,
                onLogout: onLogout
            )
            .tabItem {
                Label(AppL10n.string("navigation.home"), systemImage: "house")
            }
            .tag(AppTab.home)

            ProductListView(
                viewModel: productListViewModel,
                onAddToCart: addToCartAction,
                onStartSale: startSaleAction,
                selectedClientName: selectedClientName,
                onSelectClient: capabilities.allows(.clientManagement) ? onRequestClientSelection : nil,
                allowsSearch: capabilities.allows(.productSearch),
                allowsFavorites: capabilities.allows(.favorites),
                isFavorite: { product in
                    favoritesViewModel.isFavorite(product: product)
                },
                onToggleFavorite: { product in
                    Task {
                        await favoritesViewModel.toggle(product: product)
                    }
                }
            )
            .tabItem {
                Label(AppL10n.string("navigation.products"), systemImage: "list.bullet")
            }
            .tag(AppTab.products)

            if capabilities.allows(.favorites) {
                FavoritesView(
                    viewModel: favoritesViewModel,
                    onAddToCart: addToCartAction
                )
                .tabItem {
                    Label(AppL10n.string("navigation.favorites"), systemImage: "heart")
                }
                .tag(AppTab.favorites)
            }

            if capabilities.allows(.clientManagement) {
                ClientFlowView(
                    coordinator: clientTabCoordinator,
                    canStartSale: capabilities.allows(.startSale),
                    onClientSelected: onClientSelected,
                    onStartSale: { client in
                        onClientSelected(client)
                        selectedTab = .products
                    },
                    onClose: {
                        selectedTab = .home
                    }
                )
                .tabItem {
                    Label(AppL10n.string("navigation.clients"), systemImage: "person.2")
                }
                .tag(AppTab.clients)
            }

            if capabilities.allows(.cart) {
                CartView(
                    viewModel: cartViewModel,
                    selectedClientName: selectedClientName,
                    onCheckout: checkoutAction
                )
                .tabItem {
                    Label(AppL10n.string("navigation.cart"), systemImage: "cart")
                }
                .tag(AppTab.cart)
            }
        }
    }

    private var addToCartAction: (@MainActor @Sendable (Product) -> Void)? {
        guard capabilities.allows(.cart) else {
            return nil
        }

        return { product in
            Task {
                await cartViewModel.add(product: product)
            }
        }
    }

    private var startSaleAction: (@MainActor @Sendable (Product) -> Void)? {
        guard capabilities.allows(.startSale) else {
            return nil
        }

        return { product in
            Task {
                await cartViewModel.add(product: product)
            }
        }
    }

    private var checkoutAction: @MainActor @Sendable ([CartItem], Double) -> Void {
        guard capabilities.allows(.checkout) else {
            return { _, _ in }
        }

        return onCheckout
    }
}
