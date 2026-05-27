import DesignSystem
import SwiftUI

public struct HomeView: View {
    private let sellerName: String
    private let employeeRole: String
    private let storeName: String
    private let storeCode: String
    private let selectedClientName: String?
    private let recentClients: [HomeRecentClientState]
    private let canStartSale: Bool
    private let onStartSale: @MainActor @Sendable () -> Void
    private let onCreateClient: @MainActor @Sendable () -> Void
    private let onRecentClientSelected: @MainActor @Sendable (HomeRecentClientState) -> Void
    private let onOpenTips: @MainActor @Sendable () -> Void
    private let onLogout: @MainActor @Sendable () -> Void

    public init(
        sellerName: String,
        employeeRole: String = "",
        storeName: String = "",
        storeCode: String = "",
        selectedClientName: String? = nil,
        recentClients: [HomeRecentClientState] = [],
        canStartSale: Bool,
        onStartSale: @escaping @MainActor @Sendable () -> Void,
        onCreateClient: @escaping @MainActor @Sendable () -> Void,
        onRecentClientSelected: @escaping @MainActor @Sendable (HomeRecentClientState) -> Void = { _ in },
        onOpenTips: @escaping @MainActor @Sendable () -> Void,
        onLogout: @escaping @MainActor @Sendable () -> Void
    ) {
        self.sellerName = sellerName
        self.employeeRole = employeeRole
        self.storeName = storeName
        self.storeCode = storeCode
        self.selectedClientName = selectedClientName
        self.recentClients = recentClients
        self.canStartSale = canStartSale
        self.onStartSale = onStartSale
        self.onCreateClient = onCreateClient
        self.onRecentClientSelected = onRecentClientSelected
        self.onOpenTips = onOpenTips
        self.onLogout = onLogout
    }

    public var body: some View {
        NavigationStack {
            Form {
                Section {
                    Text(L10n.string("home.greeting", sellerName))
                        .font(.title2.weight(.semibold))

                    if !employeeRole.isEmpty {
                        Label(employeeRole, systemImage: "person.text.rectangle")
                            .foregroundStyle(.secondary)
                    }

                    Button(role: .destructive) {
                        onLogout()
                    } label: {
                        Label(L10n.string("home.logout"), systemImage: "rectangle.portrait.and.arrow.right")
                    }
                }

                if !storeName.isEmpty {
                    Section(L10n.string("home.store")) {
                        Label(storeName, systemImage: "storefront")

                        if !storeCode.isEmpty {
                            Label(storeCode, systemImage: "number")
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                Section(L10n.string("home.sale")) {
                    if let selectedClientName {
                        Label(selectedClientName, systemImage: "person.fill")
                    } else {
                        Label(L10n.string("home.noClientSelected"), systemImage: "person")
                            .foregroundStyle(.secondary)
                    }

                    Button {
                        onStartSale()
                    } label: {
                        Label(L10n.string("home.startSale"), systemImage: "cart.badge.plus")
                    }
                    .disabled(!canStartSale)
                }

                Section(L10n.string("home.client")) {
                    Button {
                        onCreateClient()
                    } label: {
                        Label(L10n.string("home.createClient"), systemImage: "person.badge.plus")
                    }
                }

                if !recentClients.isEmpty {
                    Section(L10n.string("home.recentClients")) {
                        ForEach(recentClients) { client in
                            Button {
                                onRecentClientSelected(client)
                            } label: {
                                VStack(alignment: .leading, spacing: ShopSpacing.xSmall) {
                                    Text(client.displayName)
                                        .font(.headline)
                                    Text(client.email)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                                .accessibilityElement(children: .combine)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                Section(L10n.string("home.tips")) {
                    VStack(alignment: .leading, spacing: 8) {
                        Label(L10n.string("home.learnLanguage"), systemImage: "lightbulb")
                            .font(.headline)

                        Text(L10n.string("home.tipsDescription"))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        Button {
                            onOpenTips()
                        } label: {
                            Label(L10n.string("home.openTips"), systemImage: "safari")
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle(L10n.string("home.navigationTitle"))
        }
    }
}
