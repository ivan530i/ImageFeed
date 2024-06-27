import Foundation
import UIKit

protocol ImagesListViewProtocol: AnyObject {
    func updateTableView()
    func showError(message: String)
}

protocol ImagesListPresenterProtocol: AnyObject {
    var photos: [Photo] { get }
    func viewDidLoad()
    func didTapLikeButton(at indexPath: IndexPath)
}
