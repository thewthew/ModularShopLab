import DesignSystem
import SwiftUI

public struct ClientSearchView: View {
    @State private var viewModel: ClientSearchViewModel
    private let onCreateClient: @MainActor @Sendable () -> Void
    private let onClientSelected: @MainActor @Sendable (Client) -> Void

    public init(
        viewModel: ClientSearchViewModel,
        onCreateClient: @escaping @MainActor @Sendable () -> Void,
        onClientSelected: @escaping @MainActor @Sendable (Client) -> Void
    ) {
        _viewModel = State(initialValue: viewModel)
        self.onCreateClient = onCreateClient
        self.onClientSelected = onClientSelected
    }

    public var body: some View {
        Form {
            Section {
                TextField(L10n.string("client.nameOrEmail"), text: $viewModel.searchQuery)

                PrimaryButton(L10n.string("client.search"), isLoading: viewModel.isLoading) {
                    Task {
                        await viewModel.search()
                    }
                }

                Button {
                    onCreateClient()
                } label: {
                    Label(L10n.string("client.createClient"), systemImage: "person.badge.plus")
                }
            } header: {
                Text(L10n.string("client.findClient"))
            }

            if let errorMessage = viewModel.errorMessage {
                Section {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                }
            }

            Section(L10n.string("client.results")) {
                if viewModel.clientRows.isEmpty {
                    Text(L10n.string("client.noClientsFound"))
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(viewModel.clientRows) { row in
                        Button {
                            if let client = viewModel.client(for: row) {
                                onClientSelected(client)
                            }
                        } label: {
                            ClientRow(state: row)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .navigationTitle(L10n.string("client.navigationTitle"))
        .onChange(of: viewModel.searchQuery) { _, newValue in
            if newValue.isEmpty {
                viewModel.cancel()
            } else {
                viewModel.searchDebounced()
            }
        }
    }
}

struct ClientRow: View {
    let state: ClientRowState

    var body: some View {
        VStack(alignment: .leading, spacing: ShopSpacing.xSmall) {
            Text(state.displayName)
                .font(.headline)
            Text(state.email)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text(state.countryName)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .accessibilityElement(children: .combine)
    }
}
