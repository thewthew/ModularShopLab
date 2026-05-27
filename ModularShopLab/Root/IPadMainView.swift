import ClientFeature
import FavoritesFeature
import FeatureFlags
import HomeFeature
import ProductCatalog
import ProductShowroomFeature
import SwiftUI

struct IPadMainView: View {
    let capabilities: AppCapabilities
    let sellerName: String
    let employeeRole: String
    let storeName: String
    let storeCode: String
    @Binding var selectedItem: AppSidebarItem
    let productShowroomViewModel: ProductShowroomViewModel
    let favoritesViewModel: FavoritesViewModel
    let clientCoordinator: ClientFlowCoordinator
    let selectedClientName: String?
    let onClientSelected: @MainActor @Sendable (Client) -> Void
    let onRequestClientSelection: @MainActor @Sendable () -> Void
    let onShareShowroomSelection: @MainActor @Sendable ([Product]) -> Void
    let onOpenTips: @MainActor @Sendable () -> Void
    let onLogout: @MainActor @Sendable () -> Void

    var body: some View {
        NavigationSplitView {
            List {
                sidebarButton(AppL10n.string("navigation.home"), systemImage: "house", item: .home)
                sidebarButton(AppL10n.string("navigation.products"), systemImage: "list.bullet", item: .products)

                if capabilities.allows(.favorites) {
                    sidebarButton(AppL10n.string("navigation.favorites"), systemImage: "heart", item: .favorites)
                }

                if capabilities.allows(.clientManagement) {
                    sidebarButton(AppL10n.string("navigation.clients"), systemImage: "person.2", item: .clients)
                }
            }
            .navigationTitle("ModularShopLab")
        } detail: {
            selectedView
        }
    }

    @ViewBuilder
    private var selectedView: some View {
        switch selectedItem {
        case .home:
            HomeView(
                sellerName: sellerName,
                employeeRole: employeeRole,
                storeName: storeName,
                storeCode: storeCode,
                selectedClientName: selectedClientName,
                canStartSale: capabilities.allows(.startSale),
                onStartSale: {
                    selectedItem = .products
                },
                onCreateClient: {
                    selectedItem = .clients
                },
                onOpenTips: onOpenTips,
                onLogout: onLogout
            )
        case .products:
            ProductShowroomView(
                viewModel: productShowroomViewModel,
                selectedClientName: selectedClientName,
                onSelectClient: onRequestClientSelection,
                onShareSelection: onShareShowroomSelection
            )
        case .favorites:
            if capabilities.allows(.favorites) {
                FavoritesView(viewModel: favoritesViewModel)
            } else {
                unavailableView(title: AppL10n.string("navigation.favoritesUnavailable"), systemImage: "heart.slash")
            }
        case .clients:
            if capabilities.allows(.clientManagement) {
                ClientFlowView(
                    coordinator: clientCoordinator,
                    canStartSale: capabilities.allows(.startSale),
                    onClientSelected: onClientSelected,
                    onStartSale: { client in
                        onClientSelected(client)
                    },
                    onClose: {
                        selectedItem = .home
                    }
                )
            } else {
                unavailableView(title: AppL10n.string("navigation.clientsUnavailable"), systemImage: "person.2.slash")
            }
        }
    }

    private func unavailableView(title: String, systemImage: String) -> some View {
        ContentUnavailableView(title, systemImage: systemImage)
    }

    private func sidebarButton(_ title: String, systemImage: String, item: AppSidebarItem) -> some View {
        Button {
            selectedItem = item
        } label: {
            Label(title, systemImage: systemImage)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .buttonStyle(.plain)
        .listRowBackground(selectedItem == item ? Color.accentColor.opacity(0.12) : Color.clear)
    }
}
