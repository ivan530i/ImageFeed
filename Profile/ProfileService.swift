import Foundation
import ProgressHUD

final class ProfileService {
    static let shared = ProfileService()
    
    private var task: URLSessionTask?
    private var isLoading = false
    private(set) var profile: Profile?
    
    private init() {}
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        assert(Thread.isMainThread)
        task?.cancel()
        
        guard let request = makeRequest(with: token) else {
            let errorMessage = "Invalid request - failed to create URL request"
            print("[ProfileService.fetchProfile]: \(errorMessage)")
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        
        isLoading = true
        
        task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<ProfileResult, Error>) in
            defer { self?.isLoading = false }
            guard let self = self else { return }
            switch result {
            case .success(let profileResult):
                let profile = Profile(profile: profileResult)
                self.profile = profile
                
                if let avatarURL = profileResult.profileImage?.large {
                    ProfileImageService.shared.setAvatarURL(avatarURL)
                }
                
                completion(.success(profile))
            case .failure(let error):
                print("[ProfileService.fetchProfile]: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
        
        task?.resume()
    }
    
    private func makeRequest(with token: String) -> URLRequest? {
        guard let url = URL(string: "https://api.unsplash.com/me") else {
            print("Invalid URL")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    func clearProfile() {
        profile = nil
    }
}
