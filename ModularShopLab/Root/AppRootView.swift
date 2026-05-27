import AuthFeature
import CartFeature
import ClientFeature
import FeatureFlags
import FavoritesFeature
import HomeFeature
import Observability
import PaymentFeature
import ProductCatalog
import ProductFeature
import SwiftUI

struct AppRootView: View {
    let dependencies: AppDependencies

    @State private var session: UserSession?
    @State private var selectedClient: Client?
    @State private var cartViewModel: CartViewModel
    @State private var favoritesViewModel: FavoritesViewModel
    @State private var clientTabCoordinator: ClientFlowCoordinator
    @State private var presentedClientFlow: ClientFlowCoordinator?
    @State private var presentedTipsRoute: ExternalWebRoute?
    @State private var tapToPayViewModel: TapToPayViewModel
    @State private var isCheckoutPresented = false
    @State private var selectedTab = AppTab.home
    @State private var selectedSidebarItem = AppSidebarItem.home

    init(dependencies: AppDependencies) {
        self.dependencies = dependencies
        _cartViewModel = State(initialValue: dependencies.makeCartViewModel())
        _favoritesViewModel = State(initialValue: dependencies.makeFavoritesViewModel())
        _clientTabCoordinator = State(initialValue: dependencies.makeClientFlowCoordinator())
        _tapToPayViewModel = State(initialValue: dependencies.makeTapToPayViewModel())
    }

    var body: some View {
        Group {
            if let currentSession = session {
                authenticatedContent(session: currentSession)
            } else {
                authContent
            }
        }
        .task {
            await dependencies.refreshAppContext()
        }
    }

    @ViewBuilder
    private func authenticatedContent(session currentSession: UserSession) -> some View {
        let storeContext = dependencies.makeStoreContextPresentation()
        let capabilities = dependencies.makeAppCapabilities()
        let sellerName = storeContext.employeeName.isEmpty ? currentSession.username : storeContext.employeeName

        Group {
            if AppExperience.current.isIPad {
                IPadMainView(
                    capabilities: capabilities,
                    sellerName: sellerName,
                    employeeRole: storeContext.employeeRole,
                    storeName: storeContext.storeName,
                    storeCode: storeContext.storeCode,
                    selectedItem: $selectedSidebarItem,
                    productListViewModel: dependencies.makeProductListViewModel(),
                    favoritesViewModel: favoritesViewModel,
                    clientCoordinator: clientTabCoordinator,
                    selectedClientName: selectedClient?.displayName,
                    onClientSelected: { client in
                        selectClient(client, message: "Client selected for iPad consultation.")
                    },
                    onOpenTips: {
                        openTips()
                    },
                    onLogout: {
                        logout(userID: currentSession.userID)
                    }
                )
            } else {
                MainTabs(
                    capabilities: capabilities,
                    sellerName: sellerName,
                    employeeRole: storeContext.employeeRole,
                    storeName: storeContext.storeName,
                    storeCode: storeContext.storeCode,
                    selectedTab: $selectedTab,
                    productListViewModel: dependencies.makeProductListViewModel(),
                    cartViewModel: cartViewModel,
                    favoritesViewModel: favoritesViewModel,
                    clientTabCoordinator: clientTabCoordinator,
                    selectedClientName: selectedClient?.displayName,
                    onClientSelected: { client in
                        selectClient(client, message: "Client selected for sale.")
                    },
                    onRequestClientSelection: {
                        presentClientFlow()
                    },
                    onOpenTips: {
                        openTips()
                    },
                    onLogout: {
                        logout(userID: currentSession.userID)
                    },
                    onCheckout: { items, total in
                        presentCheckout(items: items, total: total)
                    }
                )
            }
        }
        .sheet(isPresented: $isCheckoutPresented) {
            TapToPayView(viewModel: tapToPayViewModel)
        }
        .sheet(item: $presentedTipsRoute) { route in
            ExternalWebView(url: route.url)
                .ignoresSafeArea()
        }
        .fullScreenCover(item: $presentedClientFlow) { coordinator in
            ClientFlowView(
                coordinator: coordinator,
                canStartSale: capabilities.allows(.startSale),
                onClientSelected: { client in
                    selectClient(client, message: "Client selected from modal flow.")
                    closeClientFlow(coordinator)
                },
                onStartSale: { client in
                    selectClient(client, message: "Sale started from client flow.", eventName: "sale_started")
                    selectedTab = .products
                    closeClientFlow(coordinator)
                },
                onClose: {
                    presentedClientFlow = nil
                }
            )
        }
    }

    private var authContent: some View {
        AuthView(
            loginViewModel: dependencies.makeLoginViewModel(),
            registerViewModel: dependencies.makeRegisterViewModel(),
            forgotPasswordViewModel: dependencies.makeForgotPasswordViewModel(),
            allowsPasswordReset: dependencies.makeAppCapabilities().allows(.passwordReset)
        ) { session in
            self.session = session
            Task {
                await dependencies.log(
                    LogEvent(
                        name: "login_success",
                        level: .info,
                        message: "User logged in.",
                        metadata: [
                            "user_id": "\(session.userID)",
                            "username": session.username
                        ]
                    )
                )
            }
        }
    }

    private func selectClient(
        _ client: Client,
        message: String,
        eventName: String = "client_selected"
    ) {
        selectedClient = client
        Task {
            await dependencies.log(
                LogEvent(
                    name: eventName,
                    level: .info,
                    message: message,
                    metadata: ["client_id": "\(client.id)"]
                )
            )
        }
    }

    private func presentClientFlow() {
        presentedClientFlow = dependencies.makeClientFlowCoordinator()
        Task {
            await dependencies.log(
                LogEvent(
                    name: "client_flow_presented",
                    level: .debug,
                    message: "Client flow presented."
                )
            )
        }
    }

    private func closeClientFlow(_ coordinator: ClientFlowCoordinator) {
        coordinator.cancel()
        presentedClientFlow = nil
    }

    private func openTips() {
        let url = URL(string: "https://www.duolingo.com/learn")!
        presentedTipsRoute = ExternalWebRoute(url: url)
        Task {
            await dependencies.log(
                LogEvent(
                    name: "tips_webview_presented",
                    level: .info,
                    message: "Language learning tips webview presented.",
                    metadata: ["url": url.absoluteString]
                )
            )
        }
    }

    private func logout(userID: Int) {
        selectedClient = nil
        session = nil
        Task {
            await dependencies.log(
                LogEvent(
                    name: "logout",
                    level: .info,
                    message: "User logged out.",
                    metadata: ["user_id": "\(userID)"]
                )
            )
        }
    }

    private func presentCheckout(items: [CartItem], total: Double) {
        tapToPayViewModel.updateRequest(
            PaymentRequest(
                amount: Decimal(total),
                currencyCode: "USD",
                reference: "modular-shop-\(UUID().uuidString)",
                purchasedItems: items.map { item in
                    PurchasedItem(
                        id: item.product.id,
                        title: item.product.title,
                        quantity: item.quantity,
                        subtotal: Decimal(item.subtotal)
                    )
                }
            )
        )
        isCheckoutPresented = true
        Task {
            await dependencies.log(
                LogEvent(
                    name: "checkout_presented",
                    level: .info,
                    message: "Checkout presented.",
                    metadata: [
                        "has_client": selectedClient == nil ? "false" : "true",
                        "items_count": "\(items.count)",
                        "total": "\(total)"
                    ]
                )
            )
        }
    }
}
