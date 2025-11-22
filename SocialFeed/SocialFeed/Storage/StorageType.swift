import Foundation

protocol StorageType {
    func savePosts(_ posts: [PostViewItem])
    func fetchPosts(page: Int, limit: Int, completion: @escaping (Result<[PostViewItem], StorageError>) -> Void)
    func toggleLike(for postId: Int)
    func saveImageData(_ imageData: Data, for urlString: String)
    func getImageData(for urlString: String, completion: @escaping (Result<Data?, StorageError>) -> Void)
}
