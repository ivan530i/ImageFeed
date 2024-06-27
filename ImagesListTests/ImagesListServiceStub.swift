import Foundation
@testable import ImageFeed

class ImagesListServiceStub: ImagesListServiceProtocol {
    var fetchPhotosNextPageCalled = false
    var changeLikeCalled = false
    private var _photos: [Photo] = []
    var photos: [Photo] {
        return _photos
    }
    var changeLikeCompletion: ((Result<Void, Error>) -> Void)?

    static var didChangeNotification = Notification.Name("ImagesListServiceDidChange")

    func fetchPhotosNextPage() {
        fetchPhotosNextPageCalled = true
        NotificationCenter.default.post(name: ImagesListServiceStub.didChangeNotification, object: self, userInfo: ["photos": _photos])
    }

    func changeLike(photoId: String, isLike: Bool, completion: @escaping (Result<Void, Error>) -> Void) {
        changeLikeCalled = true
        changeLikeCompletion = completion
    }
    
    func setPhotos(_ photos: [Photo]) {
        _photos = photos
    }
    
    func appendPhoto(_ photo: Photo) {
        _photos.append(photo)
    }
    
    func clearPhotos() {
        _photos.removeAll()
    }
    
    func clearAll() {
        clearPhotos()
    }
}
