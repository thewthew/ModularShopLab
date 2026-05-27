import DesignSystem
import ProductCatalog
import SwiftUI

public struct ProductShowroomView: View {
    @State private var viewModel: ProductShowroomViewModel
    private let selectedClientName: String?
    private let onSelectClient: @MainActor @Sendable () -> Void
    private let onShareSelection: @MainActor @Sendable ([Product]) -> Void

    public init(
        viewModel: ProductShowroomViewModel,
        selectedClientName: String?,
        onSelectClient: @escaping @MainActor @Sendable () -> Void,
        onShareSelection: @escaping @MainActor @Sendable ([Product]) -> Void
    ) {
        _viewModel = State(initialValue: viewModel)
        self.selectedClientName = selectedClientName
        self.onSelectClient = onSelectClient
        self.onShareSelection = onShareSelection
    }

    public var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading && viewModel.products.isEmpty {
                    LoadingView(L10n.string("showroom.loading"))
                } else if let errorMessage = viewModel.errorMessage, viewModel.products.isEmpty {
                    ErrorStateView(message: errorMessage) {
                        Task {
                            await viewModel.loadProducts()
                        }
                    }
                } else {
                    showroomContent
                }
            }
            .navigationTitle(L10n.string("showroom.navigationTitle"))
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        onSelectClient()
                    } label: {
                        Label(L10n.string("showroom.selectClient"), systemImage: "person.crop.circle.badge.plus")
                    }
                }
            }
        }
        .searchable(text: $viewModel.searchQuery, prompt: Text(L10n.string("showroom.searchPrompt")))
        .onSubmit(of: .search) {
            Task {
                await viewModel.search()
            }
        }
        .onChange(of: viewModel.searchQuery) { _, newValue in
            if newValue.isEmpty {
                Task {
                    await viewModel.search()
                }
            }
        }
        .task {
            if viewModel.products.isEmpty {
                await viewModel.loadProducts()
            }
        }
    }

    private var showroomContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: ShopSpacing.large) {
                clientHeader
                productGrid
                selectionPanel
            }
            .padding(ShopSpacing.large)
        }
        .refreshable {
            await viewModel.refresh()
        }
    }

    private var clientHeader: some View {
        HStack(spacing: ShopSpacing.medium) {
            VStack(alignment: .leading, spacing: ShopSpacing.xSmall) {
                Text(L10n.string("showroom.mode"))
                    .font(.headline)
                Text(selectedClientName ?? L10n.string("showroom.noClient"))
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button {
                onSelectClient()
            } label: {
                Label(L10n.string("showroom.changeClient"), systemImage: "person")
            }
            .buttonStyle(.bordered)
        }
        .padding(ShopSpacing.medium)
        .background(ShopColors.surface, in: RoundedRectangle(cornerRadius: 8))
    }

    private var productGrid: some View {
        LazyVGrid(
            columns: [
                GridItem(.adaptive(minimum: 260), spacing: ShopSpacing.medium)
            ],
            alignment: .leading,
            spacing: ShopSpacing.medium
        ) {
            ForEach(viewModel.products) { product in
                ShowroomProductTile(
                    product: product,
                    isSelected: viewModel.isSelected(product)
                ) {
                    viewModel.toggleSelection(for: product)
                }
            }
        }
    }

    private var selectionPanel: some View {
        VStack(alignment: .leading, spacing: ShopSpacing.medium) {
            HStack {
                VStack(alignment: .leading, spacing: ShopSpacing.xSmall) {
                    Text(L10n.string("showroom.selectionTitle"))
                        .font(.headline)
                    Text(L10n.string("showroom.selectionCount", viewModel.selectedProducts.count))
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Button(L10n.string("showroom.clear")) {
                    viewModel.clearSelection()
                }
                .disabled(viewModel.selectedProducts.isEmpty)
            }

            if viewModel.selectedProducts.isEmpty {
                ContentUnavailableView(
                    L10n.string("showroom.emptySelectionTitle"),
                    systemImage: "rectangle.stack.badge.plus",
                    description: Text(L10n.string("showroom.emptySelectionDescription"))
                )
                .frame(minHeight: 180)
            } else {
                comparisonRows

                PrimaryButton(L10n.string("showroom.share")) {
                    onShareSelection(viewModel.selectedProducts)
                }
            }
        }
        .padding(ShopSpacing.medium)
        .background(ShopColors.surface, in: RoundedRectangle(cornerRadius: 8))
    }

    private var comparisonRows: some View {
        Grid(alignment: .leading, horizontalSpacing: ShopSpacing.medium, verticalSpacing: ShopSpacing.small) {
            GridRow {
                Text(L10n.string("showroom.compareProduct"))
                    .font(.caption.weight(.semibold))
                Text(L10n.string("showroom.comparePrice"))
                    .font(.caption.weight(.semibold))
                Text(L10n.string("showroom.compareNote"))
                    .font(.caption.weight(.semibold))
            }
            .foregroundStyle(.secondary)

            ForEach(viewModel.selectedProducts.prefix(4)) { product in
                GridRow {
                    Text(product.title)
                        .font(.subheadline.weight(.semibold))
                    Text(product.price.formatted(.currency(code: "USD")))
                    Text(product.description)
                        .lineLimit(2)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}

private struct ShowroomProductTile: View {
    let product: Product
    let isSelected: Bool
    let onToggleSelection: @MainActor () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: ShopSpacing.small) {
            AsyncImage(url: product.thumbnailURL) { image in
                image
                    .resizable()
                    .scaledToFit()
            } placeholder: {
                Rectangle()
                    .fill(ShopColors.surface)
                    .overlay {
                        Image(systemName: "photo")
                            .foregroundStyle(.secondary)
                    }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 160)
            .clipShape(RoundedRectangle(cornerRadius: 8))

            Text(product.title)
                .font(.headline)
                .lineLimit(2)

            Text(product.price.formatted(.currency(code: "USD")))
                .font(.subheadline.weight(.semibold))

            Text(product.description)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(3)

            Button {
                onToggleSelection()
            } label: {
                Label(
                    isSelected ? L10n.string("showroom.selected") : L10n.string("showroom.addToSelection"),
                    systemImage: isSelected ? "checkmark.circle.fill" : "plus.circle"
                )
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(isSelected ? .green : .blue)
        }
        .padding(ShopSpacing.medium)
        .background(ShopColors.surface, in: RoundedRectangle(cornerRadius: 8))
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke(isSelected ? Color.green : Color.clear, lineWidth: 2)
        }
        .accessibilityElement(children: .combine)
    }
}
