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
        let expectation = self.expectation(description: "changeLikeCalled")
        
        let view = ImagesListViewSpy()
        let service = ImagesListServiceStub()
        let presenter = ImagesListPresenter(view: view, service: service)
        
        let photo = Photo(id: "1", size: .zero, createdAt: nil, welcomeDescription: nil, thumbImageURL: "", largeImageURL: "", fullImageURL: "", isLiked: false)
        service.setPhotos([photo])
        presenter.updatePhotos()
        
        DispatchQueue.main.async {
            presenter.didTapLikeButton(at: IndexPath(row: 0, section: 0))
            XCTAssertTrue(service.changeLikeCalled)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testUpdatePhotosNotifiesView() {
        let expectation = self.expectation(description: "updateTableViewCalled")
        
        let view = ImagesListViewSpy()
        let service = ImagesListServiceStub()
        let presenter = ImagesListPresenter(view: view, service: service)
        
        let photo = Photo(id: "1", size: .zero, createdAt: nil, welcomeDescription: nil, thumbImageURL: "", largeImageURL: "", fullImageURL: "", isLiked: false)
        service.setPhotos([photo])
        
        presenter.viewDidLoad()
        presenter.updatePhotos()
        
        DispatchQueue.main.async {
            XCTAssertTrue(view.updateTableViewCalled)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testChangeLikeSuccessUpdatesPhotos() {
        let expectation = self.expectation(description: "updateTableViewCalled")
        
        let view = ImagesListViewSpy()
        let service = ImagesListServiceStub()
        let presenter = ImagesListPresenter(view: view, service: service)
        
        let photo = Photo(id: "1", size: .zero, createdAt: nil, welcomeDescription: nil, thumbImageURL: "", largeImageURL: "", fullImageURL: "", isLiked: false)
        service.setPhotos([photo])
        presenter.updatePhotos()
        
        presenter.didTapLikeButton(at: IndexPath(row: 0, section: 0))
        service.changeLikeCompletion?(.success(()))
        
        DispatchQueue.main.async {
            XCTAssertTrue(view.updateTableViewCalled)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
}
