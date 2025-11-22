import Foundation

protocol PostServiceType {
    func fetchPosts(
        page: Int,
        limit: Int,
        completion: @escaping (Result<[PostViewItem], PostServiceError>) -> Void
    )
    func toggleLike(for postId: Int)
}
