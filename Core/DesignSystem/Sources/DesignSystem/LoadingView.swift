import SwiftUI

public struct LoadingView: View {
    private let message: String

    public init(_ message: String? = nil) {
        self.message = message ?? L10n.string("loading.default")
    }

    public var body: some View {
        VStack(spacing: ShopSpacing.medium) {
            ProgressView()
            Text(message)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
