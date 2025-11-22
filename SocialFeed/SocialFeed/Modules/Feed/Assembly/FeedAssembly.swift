import UIKit

final class FeedAssembly {
    
    // MARK: Static methods
    
    static func createFeedModule() -> UIViewController {
        let urlSessionClient = URLSessionNetworkClient()
        let apiService = JsonPlaceholderService(networkClient: urlSessionClient)
        let imageCache = MemoryImageCache()
        let storageService = StorageService()
        let networkMonitor = NetworkMonitor()
        
        networkMonitor.startMonitoring()
        
        let postService = PostService(
            networkService: apiService,
            storageService: storageService,
            networkMonitor: networkMonitor
        )
        
        let imageService = ImageService(
            imageLoader: urlSessionClient,
            imageCache: imageCache,
            storageService: storageService,
            networkMonitor: networkMonitor
        )
        
        let viewModel = FeedViewModel(
            postService: postService,
            imageService: imageService
        )
        
        return FeedViewController(viewModel: viewModel)
    }
}
