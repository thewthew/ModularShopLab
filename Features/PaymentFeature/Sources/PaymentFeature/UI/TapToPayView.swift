import DesignSystem
import SwiftUI

public struct TapToPayView: View {
    @State private var viewModel: TapToPayViewModel

    public init(viewModel: TapToPayViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    public var body: some View {
        NavigationStack {
            Form {
                Section(L10n.string("payment.order")) {
                    HStack {
                        Text(L10n.string("payment.total"))
                            .font(.headline)
                        Spacer()
                        Text(viewModel.formattedAmount)
                            .font(.headline)
                    }

                    ForEach(viewModel.purchasedItems) { item in
                        HStack(alignment: .top) {
                            VStack(alignment: .leading) {
                                Text(item.title)
                                Text(L10n.string("payment.quantity", item.quantity))
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            Text(viewModel.formattedSubtotal(for: item))
                        }
                    }
                }

                Section(L10n.string("payment.tapToPay")) {
                    if let resultMessage = viewModel.resultMessage {
                        Text(resultMessage)
                            .foregroundStyle(.secondary)
                    }

                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundStyle(.red)
                    }

                    PrimaryButton(L10n.string("payment.startPayment"), isLoading: viewModel.isLoading) {
                        Task {
                            await viewModel.startPayment()
                        }
                    }
                }
            }
            .navigationTitle(L10n.string("payment.navigationTitle"))
        }
    }
}
