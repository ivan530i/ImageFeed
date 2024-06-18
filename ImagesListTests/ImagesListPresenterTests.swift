import XCTest
@testable import ImageFeed

final class ImagesListPresenterTests: XCTestCase {
    
    func testViewDidLoadFetchesPhotos() {
        let view = ImagesListViewSpy()
        let service = ImagesListServiceStub()
        let presenter = ImagesListPresenter(view: view, service: service)
        
        presenter.viewDidLoad()
        
        XCTAssertTrue(service.fetchPhotosNextPageCalled)
    }
    
    func testDidTapLikeButtonChangesLikeStatus() {
        let view = ImagesListViewSpy()
        let service = ImagesListServiceStub()
        let presenter = ImagesListPresenter(view: view, service: service)
        
        let photo = Photo(id: "1", size: .zero, createdAt: nil, welcomeDescription: nil, thumbImageURL: "", largeImageURL: "", fullImageURL: "", isLiked: false)
        service.setPhotos([photo])
        
        presenter.viewDidLoad()
        presenter.didTapLikeButton(at: IndexPath(row: 0, section: 0))
        
        XCTAssertTrue(service.changeLikeCalled)
    } 
    
    func testUpdatePhotosNotifiesView() {
        let view = ImagesListViewSpy()
        let service = ImagesListServiceStub()
        let presenter = ImagesListPresenter(view: view, service: service)
        
        let photo = Photo(id: "1", size: .zero, createdAt: nil, welcomeDescription: nil, thumbImageURL: "", largeImageURL: "", fullImageURL: "", isLiked: false)
        service.setPhotos([photo])
        
        presenter.viewDidLoad()
        presenter.updatePhotos()
        
        XCTAssertTrue(view.updateTableViewCalled)
    }
    
    func testChangeLikeSuccessUpdatesPhotos() {
        let view = ImagesListViewSpy()
        let service = ImagesListServiceStub()
        let presenter = ImagesListPresenter(view: view, service: service)
        
        let photo = Photo(id: "1", size: .zero, createdAt: nil, welcomeDescription: nil, thumbImageURL: "", largeImageURL: "", fullImageURL: "", isLiked: false)
        service.setPhotos([photo])
        
        presenter.viewDidLoad()
        presenter.didTapLikeButton(at: IndexPath(row: 0, section: 0))
        service.changeLikeCompletion?(.success(()))
        
        XCTAssertTrue(view.updateTableViewCalled)
    }
    
    func testChangeLikeFailureShowsError() {
        let view = ImagesListViewSpy()
        let service = ImagesListServiceStub()
        let presenter = ImagesListPresenter(view: view, service: service)
        
        let photo = Photo(id: "1", size: .zero, createdAt: nil, welcomeDescription: nil, thumbImageURL: "", largeImageURL: "", fullImageURL: "", isLiked: false)
        service.setPhotos([photo])
        
        presenter.viewDidLoad()
        presenter.didTapLikeButton(at: IndexPath(row: 0, section: 0))
        let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Test Error"])
        service.changeLikeCompletion?(.failure(error))
        
        XCTAssertTrue(view.showErrorCalled)
        XCTAssertEqual(view.errorMessage, "Test Error")
    }
}
