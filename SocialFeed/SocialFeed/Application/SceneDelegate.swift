import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = FeedAssembly.createFeedModule()
        window?.makeKeyAndVisible()
    }
}

final class FeedAssembly {
    static func createFeedModule() -> UIViewController {
        let networkClient = URLSessionNetworkClient()
        let apiService = JsonPlaceholderService(networkClient: networkClient)
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
            imageLoader: networkClient,
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
