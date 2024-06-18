import Foundation
@testable import ImageFeed

class ImagesListViewSpy: ImagesListViewProtocol {
    var updateTableViewCalled = false
    var showErrorCalled = false
    var errorMessage: String?
    
    func updateTableView() {
        updateTableViewCalled = true
    }
    
    func showError(message: String) {
        showErrorCalled = true
        errorMessage = message
    }
}
