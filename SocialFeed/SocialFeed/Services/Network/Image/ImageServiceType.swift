import UIKit

protocol ImageServiceType {
    func fetchImage(
        from urlString: String,
        completion: @escaping (Result<UIImage, ImageServiceError>) -> Void
    )
}
