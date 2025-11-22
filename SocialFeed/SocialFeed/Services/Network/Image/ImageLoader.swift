import UIKit

protocol ImageLoader {
    func loadImage(from url: URL, completion: @escaping (Result<Data, NetworkError>) -> Void)
}
