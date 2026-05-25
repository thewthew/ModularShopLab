import Foundation
import Observation
import Observability

@MainActor
@Observable
public final class TapToPayViewModel {
    public private(set) var request: PaymentRequest
    public private(set) var isLoading = false
    public private(set) var resultMessage: String?
    public private(set) var errorMessage: String?

    private let startTapToPayUseCase: StartTapToPayUseCase
    private let logger: (any AppLogger)?

    public init(
        startTapToPayUseCase: StartTapToPayUseCase,
        request: PaymentRequest = PaymentRequest(
            amount: 0,
            currencyCode: "EUR",
            reference: "empty-checkout"
        ),
        logger: (any AppLogger)? = nil
    ) {
        self.startTapToPayUseCase = startTapToPayUseCase
        self.request = request
        self.logger = logger
    }

    public var formattedAmount: String {
        (request.amount as NSDecimalNumber).doubleValue.formatted(.currency(code: request.currencyCode))
    }

    public var purchasedItems: [PurchasedItem] {
        request.purchasedItems
    }

    public func formattedSubtotal(for item: PurchasedItem) -> String {
        (item.subtotal as NSDecimalNumber).doubleValue.formatted(.currency(code: request.currencyCode))
    }

    public func updateRequest(_ request: PaymentRequest) {
        self.request = request
        resultMessage = nil
        errorMessage = nil
    }

    public func startPayment() async {
        guard request.amount > 0 else {
            errorMessage = L10n.string("payment.error.invalidAmount")
            await logPaymentFailure(reason: "invalid_amount")
            return
        }

        isLoading = true
        resultMessage = nil
        errorMessage = nil
        await logPaymentStarted()

        defer {
            isLoading = false
        }

        do {
            let result = try await startTapToPayUseCase.execute(request: request)
            resultMessage = message(for: result)
            await logPaymentResult(result)
        } catch PaymentError.invalidAmount {
            errorMessage = L10n.string("payment.error.invalidAmount")
            await logPaymentFailure(reason: "invalid_amount")
        } catch CheckoutPreparationError.emptyCart {
            errorMessage = L10n.string("payment.error.emptyCart")
            await logPaymentFailure(reason: "empty_cart")
        } catch {
            errorMessage = L10n.string("payment.error.failed")
            await logPaymentFailure(reason: String(describing: error))
        }
    }

    private func message(for result: PaymentResult) -> String {
        switch result.status {
        case .approved:
            L10n.string("payment.approved", result.transactionID)
        case let .declined(reason):
            L10n.string("payment.declined", reason)
        }
    }

    private func logPaymentStarted() async {
        await logger?.log(
            LogEvent(
                name: "payment_started",
                level: .info,
                message: "Tap to Pay payment started.",
                metadata: paymentMetadata()
            )
        )
    }

    private func logPaymentResult(_ result: PaymentResult) async {
        var metadata = paymentMetadata()
        metadata["transaction_id"] = result.transactionID
        metadata["status"] = result.status.loggingValue

        await logger?.log(
            LogEvent(
                name: "payment_completed",
                level: result.status.isApproved ? .info : .warning,
                message: "Tap to Pay payment completed.",
                metadata: metadata
            )
        )
    }

    private func logPaymentFailure(reason: String) async {
        var metadata = paymentMetadata()
        metadata["reason"] = reason

        await logger?.log(
            LogEvent(
                name: "payment_failed",
                level: .error,
                message: "Tap to Pay payment failed.",
                metadata: metadata
            )
        )
    }

    private func paymentMetadata() -> [String: String] {
        [
            "amount": "\(request.amount)",
            "currency": request.currencyCode,
            "items_count": "\(request.purchasedItems.count)",
            "reference": request.reference
        ]
    }
}

private extension PaymentStatus {
    var isApproved: Bool {
        if case .approved = self {
            return true
        }

        return false
    }

    var loggingValue: String {
        switch self {
        case .approved:
            "approved"
        case .declined:
            "declined"
        }
    }
}
