import AuthFeature
import CartFeature
import ClientFeature
import FavoritesFeature
import FeatureFlags
import Foundation
import Networking
import Observation
import Observability
import PaymentFeature
import ProductCatalog
import ProductFeature
import ProductShowroomFeature
import StoreContext

@MainActor
@Observable
final class AppDependencies {
    private let configuration: AppConfiguration
    private let apiClient: any APIClient
    private let authRepository: any AuthRepository
    private let clientRepository: any ClientRepository
    private let clientFeatureDependencies: ClientFeatureDependencies
    private let productRepository: any ProductRepository
    private let searchProductsUseCase: SearchProductsUseCase
    private let cartStore: any CartStore
    private let favoriteStore: any FavoriteStore
    private let checkoutPreparationService: any CheckoutPreparationService
    private let paymentService: any PaymentService
    private let logger: any AppLogger
    private let loadFeatureFlagsUseCase: LoadFeatureFlagsUseCase
    private let loadStoreContextUseCase: LoadStoreContextUseCase
    private var featureFlags: FeatureFlagSet
    private var storeContext: StoreContext

    init(configuration: AppConfiguration = .current()) {
        self.configuration = configuration

        let apiClient = URLSessionAPIClient()
        let localFeatureFlagRepository = JSONFeatureFlagRepository(dataProvider: Self.loadBundledFeatureFlagData)
        let featureFlagRepository: any FeatureFlagRepository
        let storeContextRepository: any StoreContextRepository

        switch configuration {
        case .remote:
            let remoteFeatureFlagRepository = RemoteFeatureFlagRepository(apiClient: apiClient)
            featureFlagRepository = FallbackFeatureFlagRepository(
                primary: remoteFeatureFlagRepository,
                fallback: localFeatureFlagRepository
            )
            storeContextRepository = FallbackStoreContextRepository(
                primary: RemoteStoreContextRepository(apiClient: apiClient),
                fallback: StaticStoreContextRepository()
            )
        case .mock:
            featureFlagRepository = localFeatureFlagRepository
            storeContextRepository = StaticStoreContextRepository(context: .mockRetailContext)
        }

        self.apiClient = apiClient
        self.cartStore = InMemoryCartStore()
        self.favoriteStore = InMemoryFavoriteStore()
        self.paymentService = AdyenTapToPayService()
        self.logger = CompositeLogger(loggers: [
            ConsoleLogger(),
            FirebaseLogger()
        ])
        self.loadFeatureFlagsUseCase = LoadFeatureFlagsUseCase(repository: featureFlagRepository)
        self.loadStoreContextUseCase = LoadStoreContextUseCase(repository: storeContextRepository)
        self.featureFlags = Self.loadBundledFeatureFlags()
        self.storeContext = configuration == .mock ? .mockRetailContext : .defaultRetailContext

        switch configuration {
        case .remote:
            self.authRepository = RemoteAuthRepository(apiClient: apiClient)
            self.clientRepository = RemoteClientRepository(apiClient: apiClient)
            self.productRepository = RemoteProductRepository(apiClient: apiClient)
            self.checkoutPreparationService = RemoteCheckoutPreparationWorker(apiClient: apiClient)
        case .mock:
            self.authRepository = MockAuthRepository()
            self.clientRepository = MockClientRepository()
            self.productRepository = MockProductRepository()
            self.checkoutPreparationService = MockCheckoutPreparationService()
        }

        self.clientFeatureDependencies = ClientFeatureDependencies(repository: clientRepository)
        self.searchProductsUseCase = SearchProductsUseCase(repository: productRepository)
    }

    func makeLoginViewModel() -> LoginViewModel {
        LoginViewModel(repository: authRepository)
    }

    func makeRegisterViewModel() -> RegisterViewModel {
        RegisterViewModel(repository: authRepository)
    }

    func makeForgotPasswordViewModel() -> ForgotPasswordViewModel {
        ForgotPasswordViewModel(repository: authRepository)
    }

    func makeClientFlowCoordinator() -> ClientFlowCoordinator {
        ClientFlowCoordinator(dependencies: clientFeatureDependencies)
    }

    func makeProductListViewModel() -> ProductListViewModel {
        ProductListViewModel(searchProductsUseCase: searchProductsUseCase)
    }

    func makeProductShowroomViewModel() -> ProductShowroomViewModel {
        ProductShowroomViewModel(searchProductsUseCase: searchProductsUseCase)
    }

    func makeCartViewModel() -> CartViewModel {
        CartViewModel(store: cartStore)
    }

    func makeFavoritesViewModel() -> FavoritesViewModel {
        FavoritesViewModel(store: favoriteStore)
    }

    func makeTapToPayViewModel() -> TapToPayViewModel {
        TapToPayViewModel(
            startTapToPayUseCase: StartTapToPayUseCase(
                checkoutPreparationService: checkoutPreparationService,
                paymentService: paymentService
            ),
            logger: logger
        )
    }

    func makeAppCapabilities() -> AppCapabilities {
        AppCapabilities(platform: AppExperience.current.platform, flags: featureFlags)
    }

    func makeStoreContextPresentation() -> StoreContextPresentation {
        StoreContextPresentation(
            employeeName: storeContext.employee.displayName,
            employeeRole: storeContext.employee.role.rawValue,
            storeName: storeContext.store.name,
            storeCode: storeContext.store.id
        )
    }

    func refreshAppContext() async {
        await log(
            LogEvent(
                name: "app_context_refresh_started",
                level: .debug,
                message: "App context refresh started."
            )
        )

        do {
            featureFlags = try await loadFeatureFlagsUseCase.execute()
            await log(
                LogEvent(
                    name: "feature_flags_loaded",
                    level: .info,
                    message: "Feature flags loaded.",
                    metadata: ["enabled_flags": featureFlags.enabledFlagNames.joined(separator: ",")]
                )
            )
        } catch {
            featureFlags = Self.loadBundledFeatureFlags()
            await log(
                LogEvent(
                    name: "feature_flags_load_failed",
                    level: .warning,
                    message: "Feature flags fallback loaded.",
                    metadata: ["reason": String(describing: error)]
                )
            )
        }

        do {
            storeContext = try await loadStoreContextUseCase.execute()
            await log(
                LogEvent(
                    name: "store_context_loaded",
                    level: .info,
                    message: "Store context loaded.",
                    metadata: [
                        "employee_id": storeContext.employee.id,
                        "store_id": storeContext.store.id
                    ]
                )
            )
        } catch {
            storeContext = configuration == .mock ? .mockRetailContext : .defaultRetailContext
            await log(
                LogEvent(
                    name: "store_context_load_failed",
                    level: .warning,
                    message: "Store context fallback loaded.",
                    metadata: ["reason": String(describing: error)]
                )
            )
        }
    }

    func log(_ event: LogEvent) async {
        await logger.log(enriched(event))
    }

    nonisolated private static func loadBundledFeatureFlags() -> FeatureFlagSet {
        do {
            return try FeatureFlagConfiguration.decode(from: loadBundledFeatureFlagData()).featureFlagSet
        } catch {
            return .allEnabled
        }
    }

    nonisolated private static func loadBundledFeatureFlagData() throws -> Data {
        guard let url = Bundle.main.url(forResource: "FeatureFlags", withExtension: "json") else {
            throw FeatureFlagLoadingError.missingLocalConfiguration
        }

        return try Data(contentsOf: url)
    }

    private func enriched(_ event: LogEvent) -> LogEvent {
        var metadata = event.metadata
        metadata["configuration"] = configuration.loggingValue
        metadata["platform"] = AppExperience.current.platform.loggingValue

        return LogEvent(
            name: event.name,
            level: event.level,
            message: event.message,
            metadata: metadata
        )
    }
}

private extension AppConfiguration {
    var loggingValue: String {
        switch self {
        case .remote:
            "remote"
        case .mock:
            "mock"
        }
    }
}

private extension AppPlatform {
    var loggingValue: String {
        switch self {
        case .iPhone:
            "iphone"
        case .iPad:
            "ipad"
        }
    }
}

private extension FeatureFlagSet {
    var enabledFlagNames: [String] {
        FeatureFlag.allCases
            .filter { isEnabled($0) }
            .map(\.rawValue)
    }
}
