import Foundation

protocol NetworkClient {
    func sendRequest<T: Decodable>(
        _ request: NetworkRequest,
        completion: @escaping (Result<T, NetworkError>) -> Void
    )
}
