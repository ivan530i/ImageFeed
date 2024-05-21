import UIKit

final class ProfileImageService {
    
    static let shared = ProfileImageService()
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    private var task: URLSessionTask?
    private let urlSession = URLSession.shared
    private let oauthToken = OAuth2TokenStorage().token
    private(set) var avatarURL: String?
    
    private init() {}
    
    func fetchProfileImageURL(
        username: String,
        _ completion: @escaping (Result<String, Error>) -> Void
    ) {
        assert(Thread.isMainThread)
        if task != nil {
            return
        }
        
        task?.cancel()
        
        guard let token = oauthToken else { return }
        
        let request = profileImageRequest(token: token, username: username)
        
        task = urlSession.objectTask(for: request) { [weak self] (result: Result<ProfileResult, Error>) in
            guard let self = self else { return }
            switch result {
            case .success(let userResult):
                guard let avatarUrl = userResult.profileImage?.large else {
                    print("Error: [ProfileImageService] image is nill")
                    completion(.failure(NetworkError.imageError))
                    return
                }
                
                self.avatarURL = avatarUrl
                DispatchQueue.main.async {
                    completion(.success(avatarUrl))
                    NotificationCenter.default.post(name: ProfileImageService.didChangeNotification,
                                                    object: self,
                                                    userInfo: ["URL": avatarUrl])
                }
            case .failure(let error):
                print("[ProfileImageService.fetchProfileImageURL]: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
        
        task?.resume()
    }
    
    private func profileImageRequest(token: String, username: String) -> URLRequest {
        guard let url = URL(string: "https://api.unsplash.com/users/\(username)") else {
            fatalError("Failed to create URL")
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}
