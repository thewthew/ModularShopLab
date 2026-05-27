import DesignSystem
import ProductCatalog
import SwiftUI

public struct CartView: View {
    @State private var viewModel: CartViewModel
    private let selectedClientName: String?
    private let onCheckout: @MainActor @Sendable ([CartItem], Double) -> Void

    public init(
        viewModel: CartViewModel,
        selectedClientName: String? = nil,
        onCheckout: @escaping @MainActor @Sendable ([CartItem], Double) -> Void = { _, _ in }
    ) {
        _viewModel = State(initialValue: viewModel)
        self.selectedClientName = selectedClientName
        self.onCheckout = onCheckout
    }

    public var body: some View {
        NavigationStack {
            Group {
                if viewModel.items.isEmpty {
                    ContentUnavailableView(
                        L10n.string("cart.emptyTitle"),
                        systemImage: "cart",
                        description: Text(L10n.string("cart.emptyDescription"))
                    )
                } else {
                    List {
                        Section(L10n.string("cart.client")) {
                            if let selectedClientName {
                                Label(selectedClientName, systemImage: "person.fill")
                            } else {
                                Label(L10n.string("cart.selectClientBeforeCheckout"), systemImage: "person.crop.circle.badge.exclamationmark")
                                    .foregroundStyle(.secondary)
                            }
                        }

                        ForEach(viewModel.items) { item in
                            HStack(alignment: .top, spacing: ShopSpacing.medium) {
                                VStack(alignment: .leading, spacing: ShopSpacing.xSmall) {
                                    Text(item.product.title)
                                        .font(.headline)
                                    Text(L10n.string("cart.quantity", item.quantity))
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }

                                Spacer()

                                Text(item.subtotal.formatted(.currency(code: "USD")))
                                    .font(.subheadline.weight(.semibold))
                            }
                        }
                        .onDelete { indexSet in
                            Task {
                                for index in indexSet {
                                    await viewModel.remove(productID: viewModel.items[index].product.id)
                                }
                            }
                        }

                        Section {
                            HStack {
                                Text(L10n.string("cart.total"))
                                    .font(.headline)
                                Spacer()
                                Text(viewModel.total.formatted(.currency(code: "USD")))
                                    .font(.headline)
                            }

                            Button {
                                onCheckout(viewModel.items, viewModel.total)
                            } label: {
                                Label(L10n.string("cart.checkout"), systemImage: "creditcard")
                            }
                            .disabled(viewModel.items.isEmpty || selectedClientName == nil)
                        }
                    }
                }
            }
            .navigationTitle(L10n.string("cart.navigationTitle"))
        }
        .task {
            await viewModel.loadCart()
        }
    }
}
