import Foundation

final class URLSessionNetworkClient {
    
    // MARK: Private properties
    
    private let urlSession: URLSession
    private let decoder: JSONDecoder
    
    // MARK: Init
    
    init(
        urlSession: URLSession = .shared,
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.urlSession = urlSession
        self.decoder = decoder
    }
}

// MARK: NetworkClient

extension URLSessionNetworkClient: NetworkClient {
    
    func sendRequest<T: Decodable>(
        _ request: NetworkRequest,
        completion: @escaping (Result<T, NetworkError>) -> Void
    ) {
        let urlRequest = URLRequest(url: request.url)
        
        urlSession.dataTask(with: urlRequest) { data, response, error in
            
            if let _ = error {
                completion(.failure(.unableToComplete))
                return
            }
            
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                completion(.failure(.invalidResponse))
                return
            }
            
            guard let data = data else {
                completion(.failure(.invalidData))
                return
            }
            
            let decoder = JSONDecoder()
            
            do {
                let dataModel = try decoder.decode(T.self, from: data)
                completion(.success(dataModel))
            } catch {
                completion(.failure(.invalidDecode))
            }
        }.resume()
    }
}
