import Foundation

final class OAuth2Service {
    static let shared = OAuth2Service()
    
    let tokenStorage = OAuth2TokenStorage()
    
    private init() {}
    
    private (set) var authToken: String? {
        get { tokenStorage.token }
        set { tokenStorage.token = newValue }
    }
    
    func fetchOAuthToken(with code: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let request = makeTokenRequest(with: code) else {
            let error = NSError(domain: "OAuth2Service", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to create token request."])
            completion(.failure(NetworkError.urlRequestError(error)))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(NetworkError.urlRequestError(error)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NetworkError.urlSessionError))
                return
            }
            
            guard (200..<300).contains(httpResponse.statusCode) else {
                completion(.failure(NetworkError.httpStatusCode(httpResponse.statusCode)))
                return
            }
            
            guard let data = data else {
                completion(.failure(NetworkError.urlSessionError))
                return
            }
            
            do {
                let tokenResponse = try JSONDecoder().decode(OAuthTokenResponseBody.self, from: data)
                let accessToken = tokenResponse.accessToken
                self.tokenStorage.token = accessToken
                DispatchQueue.main.async {
                    completion(.success(accessToken))
                }
            } catch {
                print("Error decoding token response: \(error)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
    
    private func makeTokenRequest(with code: String) -> URLRequest? {
        guard let url = URL(string: "https://unsplash.com/oauth/token") else {
            print("Error: Failed to create URL for token request")
            return nil
        }
        
        let accessKey = Constants.accessKey
        let secretKey = Constants.secretKey
        let redirectURI = Constants.redirectURI
        
        let params: [String: Any] = [
            "client_id": accessKey,
            "client_secret": secretKey,
            "redirect_uri": redirectURI,
            "code": code,
            "grant_type": "authorization_code"
        ]
        
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            urlRequest.httpBody = try JSONSerialization.data(withJSONObject: params, options: [])
            return urlRequest
        } catch {
            print("Error creating token request: \(error)")
            return nil
        }
    }
}

