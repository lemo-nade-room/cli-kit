import AsyncHTTPClient
import ConsoleKit

extension CommandContext {
    /// HTTPクライアント
    public var client: AsyncHTTPClient.HTTPClient {
        get async {
            await storage.get {
                await .init(eventLoopGroup: eventLoopGroup.any())
            }
        }
    }
}
