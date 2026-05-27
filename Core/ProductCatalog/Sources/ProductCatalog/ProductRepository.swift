public protocol ProductRepository: Sendable {
    func products() async throws -> [Product]
    func searchProducts(query: String) async throws -> [Product]
}
