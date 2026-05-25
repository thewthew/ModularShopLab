import DesignSystem
import SwiftUI

public struct ClientFormView: View {
    @State private var viewModel: ClientFormViewModel
    private let onSaved: @MainActor @Sendable (Client) -> Void

    public init(
        viewModel: ClientFormViewModel,
        onSaved: @escaping @MainActor @Sendable (Client) -> Void
    ) {
        _viewModel = State(initialValue: viewModel)
        self.onSaved = onSaved
    }

    public var body: some View {
        Form {
            Section(L10n.string("client.identity")) {
                TextField(L10n.string("client.firstName"), text: $viewModel.firstName)
                TextField(L10n.string("client.lastName"), text: $viewModel.lastName)
                TextField(L10n.string("client.email"), text: $viewModel.email)
                TextField(L10n.string("client.phone"), text: $viewModel.phone)
            }

            Section(L10n.string("client.origin")) {
                Picker(L10n.string("client.country"), selection: $viewModel.country) {
                    ForEach(ClientCountry.allCases) { country in
                        Text(country.localizedName)
                            .tag(country)
                    }
                }
            }

            if let errorMessage = viewModel.errorMessage {
                Section {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                }
            }

            Section {
                PrimaryButton(viewModel.submitTitle, isLoading: viewModel.isLoading) {
                    Task {
                        if let client = await viewModel.save() {
                            onSaved(client)
                        }
                    }
                }
            }
        }
        .navigationTitle(viewModel.title)
    }
}
