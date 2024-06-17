import Foundation

final class ImagesListPresenter: ImagesListPresenterProtocol {
    weak var view: ImagesListViewProtocol?
    private let imageListService: ImagesListServiceProtocol
    
    private(set) var photos: [Photo] = []
    
    init(view: ImagesListViewProtocol, service: ImagesListServiceProtocol = ImagesListService.shared) {
        self.view = view
        self.imageListService = service
        NotificationCenter.default.addObserver(self, selector: #selector(updatePhotos), name: ImagesListService.didChangeNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func viewDidLoad() {
        imageListService.fetchPhotosNextPage()
    }
    
    func didTapLikeButton(at indexPath: IndexPath) {
        let photo = photos[indexPath.row]
        UIBlockingProgressHUD.show()
        
        imageListService.changeLike(photoId: photo.id, isLike: !photo.isLiked) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                UIBlockingProgressHUD.dismiss()
                
                switch result {
                case .success:
                    self.photos = self.imageListService.photos
                    self.view?.updateTableView()
                case .failure(let error):
                    self.view?.showError(message: error.localizedDescription)
                }
            }
        }
    }
    
    @objc func updatePhotos() {
        photos = imageListService.photos
        view?.updateTableView()
    }
}
