import Alamofire
import UIKit

final class AlamofireNetworkClient {
    
    // MARK: Private properties
    
    private let session: Session
    private let decoder: JSONDecoder
    
    // MARK: Init
    
    init(
        session: Session = .default,
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.session = session
        self.decoder = decoder
    }
}

// MARK: - NetworkClient

extension AlamofireNetworkClient: NetworkClient {
    
    func sendRequest<T: Decodable>(
        _ request: NetworkRequest,
        completion: @escaping (Result<T, NetworkError>) -> Void
    ) {
        session.request(request.url)
            .validate()
            .responseDecodable(of: T.self, decoder: decoder) { response in
                switch response.result {
                case .success(let data):
                    completion(.success(data))
                case .failure(let error):
                    let networkError = self.mapAFError(error)
                    completion(.failure(networkError))
                }
            }
    }
}

// MARK: ImageLoader

extension AlamofireNetworkClient: ImageLoader {
    func loadImage(
        from url: URL,
        completion: @escaping (Result<UIImage, NetworkError>) -> Void
    ) {
        session.request(url)
            .validate()
            .responseData { response in
                switch response.result {
                case .success(let data):
                    if let image = UIImage(data: data) {
                        completion(.success(image))
                    } else {
                        completion(.failure(.invalidDecode))
                    }
                case .failure(let error):
                    let networkError = self.mapAFError(error)
                    completion(.failure(networkError))
                }
            }
    }
}

// MARK: - Private Methods

private extension AlamofireNetworkClient {
    func mapAFError(_ error: AFError) -> NetworkError {
        if error.isResponseValidationError {
            return .invalidResponse
        } else if error.isResponseSerializationError {
            return .invalidDecode
        } else if error.isSessionTaskError {
            return .unableToComplete
        } else {
            return .invalidData
        }
    }
}
