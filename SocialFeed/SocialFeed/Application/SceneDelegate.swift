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
        window?.rootViewController = FeedViewController(
            apiService: apiService,
            storageService: storageService,
            imageService: imageService,
            postService: postService
        )
        window?.makeKeyAndVisible()
    }
}
