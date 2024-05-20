import Foundation
import WebKit

enum NetworkError: Error {
    case urlSessionError
    case invalidRequest
    case decodingError
    case imageError
    case errorReceivingProfile
    case httpStatusCode(Int, String)
    case urlRequestError(Error)
}

extension URLSession {
    func objectTask<T: Decodable>(
        for request: URLRequest,
        completion: @escaping (Result<T, Error>) -> Void
    ) -> URLSessionTask {
        let fulfillCompletionOnTheMainThread: (Result<T, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("[objectTask]: URLRequest error - \(error.localizedDescription)")
                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlRequestError(error)))
                return
            }
            
            guard let data = data, let response = response, let statusCode = (response as? HTTPURLResponse)?.statusCode else {
                print("[objectTask]: URLSession error - no data or response")
                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlSessionError))
                return
            }
            
            if !(200 ..< 300).contains(statusCode) {
                let errorMessage = HTTPURLResponse.localizedString(forStatusCode: statusCode)
                print("[objectTask]: HTTP error - status code \(statusCode), message: \(errorMessage)")
                fulfillCompletionOnTheMainThread(.failure(NetworkError.httpStatusCode(statusCode, errorMessage)))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let result = try decoder.decode(T.self, from: data)
                fulfillCompletionOnTheMainThread(.success(result))
            } catch {
                print("Ошибка декодирования: \(error.localizedDescription), Данные: \(String(data: data, encoding: .utf8) ?? "")")
                fulfillCompletionOnTheMainThread(.failure(NetworkError.decodingError))
            }
        }
        task.resume()
        return task
    }
}

