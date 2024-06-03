import UIKit

final class ImagesListService {
    private (set) var photos: [Photo] = []
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    private var task: URLSessionTask?
    private var lastPage = 1
    static let shared = ImagesListService()
    private let urlSession = URLSession.shared
    
    private init() {}
    
    func fetchPhotosNextPage() {
        assert(Thread.isMainThread)
        
        if task != nil {
            return
        }
        
        guard let request = getImagesListRequest(page: lastPage) else {
            print("Error creating request")
            return
        }
        
        task = urlSession.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            self.task = nil
            
            if let error = error {
                print("Error: \(error)")
                return
            }
            
            guard let data = data else {
                print("No data received")
                return
            }
            
            do {
                let photoResults = try JSONDecoder().decode([PhotoResult].self, from: data)
                
                DispatchQueue.main.async {
                    photoResults.forEach {
                        self.photos.append(
                            Photo(
                                id: $0.id,
                                size: CGSize(width: $0.width, height: $0.height),
                                createdAt: self.formatISODateString($0.createdAt),
                                welcomeDescription: $0.description,
                                thumbImageURL: $0.urls.thumb,
                                largeImageURL: $0.urls.full,
                                fullImageURL: $0.urls.full,
                                isLiked: $0.likedByUser
                            )
                        )
                    }
                    
                    NotificationCenter.default.post(
                        name: ImagesListService.didChangeNotification,
                        object: self,
                        userInfo: ["photos": self.photos]
                    )
                    self.lastPage += 1
                }
            } catch {
                print("Error decoding JSON: \(error)")
            }
        }
        
        task?.resume()
    }
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        let urlString = "https://api.unsplash.com/photos/\(photoId)/like"
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = isLike ? "POST" : "DELETE"
        request.setValue("Client-ID UtikJ6aDHAwv8C_JVCEbQLQJ7ldEw_D3LVCSYvRfiyI", forHTTPHeaderField: "Authorization")
        
        let task = urlSession.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
                let photo = self.photos[index]
                let newPhoto = Photo(
                    id: photo.id,
                    size: photo.size,
                    createdAt: photo.createdAt,
                    welcomeDescription: photo.welcomeDescription,
                    thumbImageURL: photo.thumbImageURL,
                    largeImageURL: photo.largeImageURL,
                    fullImageURL: photo.fullImageURL,
                    isLiked: isLike
                )
                
                DispatchQueue.main.async {
                    self.photos[index] = newPhoto
                    NotificationCenter.default.post(
                        name: ImagesListService.didChangeNotification,
                        object: self,
                        userInfo: ["photos": self.photos]
                    )
                    completion(.success(()))
                }
            } else {
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "Photo not found", code: 0, userInfo: nil)))
                }
            }
        }
        
        task.resume()
    }
    
    private func getImagesListRequest(page: Int) -> URLRequest? {
        var components = URLComponents(string: "https://api.unsplash.com/photos")
        components?.queryItems = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "per_page", value: "10"),
            URLQueryItem(name: "client_id", value: "UtikJ6aDHAwv8C_JVCEbQLQJ7ldEw_D3LVCSYvRfiyI")
        ]
        
        guard let url = components?.url else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        return request
    }
    
    private func formatISODateString(_ dateString: String?) -> Date? {
        guard let dateString = dateString else { return nil }
        let formatter = ISO8601DateFormatter()
        return formatter.date(from: dateString)
    }
}
