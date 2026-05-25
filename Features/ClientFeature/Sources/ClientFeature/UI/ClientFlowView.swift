import SwiftUI

public struct ClientFlowView: View {
    @State private var coordinator: ClientFlowCoordinator
    private let canStartSale: Bool
    private let onClientSelected: @MainActor @Sendable (Client) -> Void
    private let onStartSale: @MainActor @Sendable (Client) -> Void
    private let onClose: @MainActor @Sendable () -> Void

    public init(
        coordinator: ClientFlowCoordinator,
        canStartSale: Bool = true,
        onClientSelected: @escaping @MainActor @Sendable (Client) -> Void,
        onStartSale: @escaping @MainActor @Sendable (Client) -> Void,
        onClose: @escaping @MainActor @Sendable () -> Void
    ) {
        _coordinator = State(initialValue: coordinator)
        self.canStartSale = canStartSale
        self.onClientSelected = onClientSelected
        self.onStartSale = onStartSale
        self.onClose = onClose
    }

    public var body: some View {
        NavigationStack(path: $coordinator.path) {
            ClientSearchView(
                viewModel: coordinator.searchViewModel,
                onCreateClient: {
                    coordinator.showCreate()
                },
                onClientSelected: { client in
                    coordinator.showDetail(for: client)
                }
            )
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L10n.string("client.close")) {
                        coordinator.cancel()
                        onClose()
                    }
                }
            }
            .navigationDestination(for: ClientFlowRoute.self) { route in
                switch route {
                case let .detail(client):
                    ClientDetailView(
                        state: ClientDetailViewState(client: client),
                        canStartSale: canStartSale,
                        onSelectClient: {
                            onClientSelected(client)
                        },
                        onStartSale: {
                            onStartSale(client)
                        },
                        onUpdate: {
                            coordinator.showUpdate(for: client)
                        }
                    )
                case .create:
                    ClientFormView(viewModel: coordinator.makeCreateViewModel()) { client in
                        onClientSelected(client)
                        coordinator.showDetail(for: client)
                    }
                case let .update(client):
                    ClientFormView(viewModel: coordinator.makeUpdateViewModel(for: client)) { updatedClient in
                        onClientSelected(updatedClient)
                        coordinator.path.removeAll { $0 == .detail(client) || $0 == .update(client) }
                        coordinator.showDetail(for: updatedClient)
                    }
                }
            }
        }
    }
}
