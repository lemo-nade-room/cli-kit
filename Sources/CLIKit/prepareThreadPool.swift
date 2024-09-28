import NIOCore
import NIOPosix

func prepareThreadPool() async throws -> NIOThreadPool {
    let threadPool = NIOThreadPool(numberOfThreads: System.coreCount)
    try await threadPool.shutdownGracefully()
    threadPool.start()
    return threadPool
}
