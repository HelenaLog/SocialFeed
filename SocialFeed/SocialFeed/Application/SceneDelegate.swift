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
        let imageService = ImageService(imageLoader: networkClient, imageCache: imageCache)
        window?.rootViewController = FeedViewController(apiService: apiService, imageService: imageService)
        window?.makeKeyAndVisible()
    }
}
