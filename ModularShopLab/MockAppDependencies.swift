import AuthFeature
import ClientFeature
import FeatureFlags
import Foundation
import PaymentFeature
import ProductCatalog
import ProductFeature
import StoreContext

struct MockAuthRepository: AuthRepository {
    func login(credentials: LoginCredentials) async throws -> UserSession {
        guard !credentials.username.isEmpty, !credentials.password.isEmpty else {
            throw AuthError.emptyFields
        }

        return UserSession(
            userID: 1001,
            username: credentials.username,
            accessToken: "mock-access-token"
        )
    }

    func register(credentials: RegisterCredentials) async throws -> UserSession {
        guard !credentials.username.isEmpty, !credentials.password.isEmpty else {
            throw AuthError.emptyFields
        }

        return UserSession(
            userID: 1002,
            username: credentials.username,
            accessToken: "mock-registered-token"
        )
    }

    func requestPasswordReset(_ request: PasswordResetRequest) async throws {
        guard !request.usernameOrEmail.isEmpty else {
            throw AuthError.emptyFields
        }
    }
}

struct MockProductRepository: ProductRepository {
    private let mockProducts: [Product]

    init(mockProducts: [Product] = Self.defaultProducts) {
        self.mockProducts = mockProducts
    }

    func products() async throws -> [Product] {
        mockProducts
    }

    func searchProducts(query: String) async throws -> [Product] {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else {
            return mockProducts
        }

        return mockProducts.filter { product in
            product.title.localizedCaseInsensitiveContains(trimmedQuery)
            || product.description.localizedCaseInsensitiveContains(trimmedQuery)
        }
    }

    private static let defaultProducts = [
        Product(
            id: 1,
            title: "Mock Running Jacket",
            price: 129.99,
            description: "Lightweight retail demo product for in-store sales flows.",
            thumbnailURL: URL(string: "https://picsum.photos/seed/modular-shop-jacket/320/240")
        ),
        Product(
            id: 2,
            title: "Mock Trail Shoes",
            price: 159.50,
            description: "Cushioned shoes with a mock stock-ready product description.",
            thumbnailURL: URL(string: "https://picsum.photos/seed/modular-shop-shoes/320/240")
        ),
        Product(
            id: 3,
            title: "Mock Store Backpack",
            price: 89.00,
            description: "Everyday backpack used to test cart, favorites and checkout.",
            thumbnailURL: URL(string: "https://picsum.photos/seed/modular-shop-backpack/320/240")
        )
    ]
}

actor MockClientRepository: ClientRepository {
    private var clients = [
        Client(
            id: 1,
            firstName: "Camille",
            lastName: "Martin",
            email: "camille.martin@example.com",
            phone: "+33123456789",
            country: .france
        ),
        Client(
            id: 2,
            firstName: "Alex",
            lastName: "Taylor",
            email: "alex.taylor@example.com",
            phone: "+442012345678",
            country: .unitedKingdom
        )
    ]

    func searchClients(query: String) async throws -> [Client] {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else {
            return clients
        }

        return clients.filter { client in
            client.displayName.localizedCaseInsensitiveContains(trimmedQuery)
            || client.email.localizedCaseInsensitiveContains(trimmedQuery)
        }
    }

    func createClient(_ request: CreateClientRequest) async throws -> Client {
        guard !request.firstName.isEmpty, !request.lastName.isEmpty, !request.email.isEmpty else {
            throw ClientError.emptyRequiredFields
        }

        let nextID = (clients.map(\.id).max() ?? 0) + 1
        let client = Client(
            id: nextID,
            firstName: request.firstName,
            lastName: request.lastName,
            email: request.email,
            phone: request.phone,
            country: request.country
        )
        clients.append(client)
        return client
    }

    func updateClient(_ request: UpdateClientRequest) async throws -> Client {
        guard !request.firstName.isEmpty, !request.lastName.isEmpty, !request.email.isEmpty else {
            throw ClientError.emptyRequiredFields
        }

        let client = Client(
            id: request.id,
            firstName: request.firstName,
            lastName: request.lastName,
            email: request.email,
            phone: request.phone,
            country: request.country
        )

        if let index = clients.firstIndex(where: { $0.id == request.id }) {
            clients[index] = client
        } else {
            clients.append(client)
        }

        return client
    }
}

struct MockCheckoutPreparationService: CheckoutPreparationService {
    func prepareCheckout(request: CheckoutPreparationRequest) async throws -> CheckoutPreparationResult {
        guard request.paymentRequest.amount > 0 else {
            throw CheckoutPreparationError.invalidAmount
        }

        guard !request.paymentRequest.purchasedItems.isEmpty else {
            throw CheckoutPreparationError.emptyCart
        }

        return CheckoutPreparationResult(
            paymentRequest: request.paymentRequest,
            orderReference: "mock-order-\(request.paymentRequest.reference)"
        )
    }
}

extension StoreContext {
    static let mockRetailContext = StoreContext(
        store: Store(
            id: "MOCK-001",
            name: "Mock Retail Lab",
            countryCode: "FR",
            currencyCode: "EUR"
        ),
        employee: Employee(
            id: "MOCK-EMP-001",
            displayName: "Mock Seller",
            role: .manager
        ),
        salesChannel: .clienteling
    )
}
