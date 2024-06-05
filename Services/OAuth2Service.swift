import Foundation
import ProgressHUD

enum AuthServiceError: Error {
    case invalidRequest
}

final class OAuth2Service {
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var ongoingCode: String?
    
    static let shared = OAuth2Service()
    
    let tokenStorage = OAuth2TokenStorage()
    
    private init() {}
    
    var authToken: String? {
        get { tokenStorage.token }
        set { tokenStorage.token = newValue }
    }
    
    func fetchOAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        if let existingTask = task {
            if ongoingCode == code {
                
                let errorMessage = "Invalid request - duplicate code"
                print("[OAuth2Service.fetchOAuthToken]: \(errorMessage)")
                completion(.failure(AuthServiceError.invalidRequest))
                return
            } else {
                existingTask.cancel()
            }
        }
        
        ongoingCode = code
        
        guard let request = makeTokenRequest(with: code) else {
            let errorMessage = "Invalid request - failed to create URL request"
            print("[OAuth2Service.fetchOAuthToken]: \(errorMessage)")
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }
        
        task = urlSession.objectTask(for: request) { [weak self] (result: Result<OAuthTokenResponseBody, Error>) in
            guard let self = self else { return }
            
            defer {
                DispatchQueue.main.async {
                    self.task = nil
                    self.ongoingCode = nil
                }
            }
            
            switch result {
            case .success(let tokenResponse):
                let accessToken = tokenResponse.accessToken
                self.authToken = accessToken
                DispatchQueue.main.async {
                    completion(.success(accessToken))
                }
            case .failure(let error):
                print("[OAuth2Service.fetchOAuthToken]: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
        
        task?.resume()
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
    
    func clearToken() {
        tokenStorage.token = nil
    }
}
