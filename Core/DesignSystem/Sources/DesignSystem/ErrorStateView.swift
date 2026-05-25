import SwiftUI

public struct ErrorStateView: View {
    private let message: String
    private let retry: (@MainActor () -> Void)?

    public init(
        message: String,
        retry: (@escaping @MainActor () -> Void)
    ) {
        self.message = message
        self.retry = retry
    }

    public init(message: String) {
        self.message = message
        self.retry = nil
    }

    public var body: some View {
        ContentUnavailableView {
            Label(L10n.string("error.title"), systemImage: "exclamationmark.triangle")
        } description: {
            Text(message)
        } actions: {
            if let retry {
                Button(L10n.string("error.retry"), action: retry)
                    .buttonStyle(.borderedProminent)
            }
        }
    }
}
