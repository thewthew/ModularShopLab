import SwiftUI

public struct ClientDetailView: View {
    private let state: ClientDetailViewState
    private let canStartSale: Bool
    private let onSelectClient: @MainActor @Sendable () -> Void
    private let onStartSale: @MainActor @Sendable () -> Void
    private let onUpdate: @MainActor @Sendable () -> Void

    public init(
        state: ClientDetailViewState,
        canStartSale: Bool = true,
        onSelectClient: @escaping @MainActor @Sendable () -> Void,
        onStartSale: @escaping @MainActor @Sendable () -> Void,
        onUpdate: @escaping @MainActor @Sendable () -> Void
    ) {
        self.state = state
        self.canStartSale = canStartSale
        self.onSelectClient = onSelectClient
        self.onStartSale = onStartSale
        self.onUpdate = onUpdate
    }

    public var body: some View {
        Form {
            Section(L10n.string("client.client")) {
                LabeledContent(L10n.string("client.name"), value: state.displayName)
                LabeledContent(L10n.string("client.email"), value: state.email)
                if let phone = state.phone {
                    LabeledContent(L10n.string("client.phone"), value: phone)
                }
                LabeledContent(L10n.string("client.country"), value: state.countryName)
            }

            Section(L10n.string("client.sale")) {
                Button {
                    onSelectClient()
                } label: {
                    Label(L10n.string("client.selectClient"), systemImage: "person.fill.checkmark")
                }

                if canStartSale {
                    Button {
                        onStartSale()
                    } label: {
                        Label(L10n.string("client.startSale"), systemImage: "cart.badge.plus")
                    }
                }
            }

            Section {
                Button {
                    onUpdate()
                } label: {
                    Label(L10n.string("client.updateClient"), systemImage: "pencil")
                }
            }
        }
        .navigationTitle(state.title)
    }
}
