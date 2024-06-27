import Foundation
import UIKit

protocol ImagesListServiceProtocol: AnyObject {
    var photos: [Photo] { get }
    static var didChangeNotification: Notification.Name { get }
    func fetchPhotosNextPage()
    func changeLike(photoId: String, isLike: Bool, completion: @escaping (Result<Void, Error>) -> Void)
    func clearAll()
}
