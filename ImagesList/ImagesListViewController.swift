import UIKit

final class ImagesListViewController: UIViewController, ImagesListCellDelegate, ImagesListViewProtocol {
    
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    private var presenter: ImagesListPresenterProtocol!
    
    @IBOutlet private var tableView: UITableView!
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM yyyy"
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter = ImagesListPresenter(view: self)
        tableView.rowHeight = 200
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        
        presenter.viewDidLoad()
    }
    
    func updateTableView() {
        tableView.reloadData()
    }
    
    func showError(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        presenter.didTapLikeButton(at: indexPath)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            guard
                let viewController = segue.destination as? SingleImageViewController,
                let indexPath = sender as? IndexPath,
                indexPath.row < presenter.photos.count
            else {
                assertionFailure("Invalid segue destination or indexPath out of range")
                return
            }
            
            let photo = presenter.photos[indexPath.row]
            viewController.imageUrl = URL(string: photo.fullImageURL)
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard indexPath.row < presenter.photos.count else {
            return 0
        }
        
        let photo = presenter.photos[indexPath.row]
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageWidth = photo.size.width
        let scale = imageViewWidth / imageWidth
        let cellHeight = photo.size.height * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row + 1 == presenter.photos.count && !ProcessInfo.processInfo.arguments.contains("UITEST") {
            presenter.viewDidLoad()
        }
    }
}


extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath) as! ImagesListCell
        configCell(for: cell, with: indexPath)
        return cell
    }
}

extension ImagesListViewController {
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        let photo = presenter.photos[indexPath.row]
        
        cell.delegate = self
        
        cell.cellImage.kf.cancelDownloadTask()
        
        cell.cellImage.kf.indicatorType = .activity
        cell.cellImage.kf.setImage(
            with: URL(string: photo.largeImageURL),
            placeholder: UIImage(named: "Stub"),
            options: [
                .transition(.fade(0.2))
            ],
            completionHandler: { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case .success:
                    self.tableView.beginUpdates()
                    self.tableView.endUpdates()
                case .failure(let error):
                    print("Error loading image: \(error)")
                }
            })
        
        cell.dateLabel.text = photo.createdAt.map { dateFormatter.string(from: $0) } ?? ""
        
        let likeImage = photo.isLiked ? UIImage(named: "like_button_on") : UIImage(named: "like_button_off")
        cell.likeButton.setImage(likeImage, for: .normal)
        cell.likeButton.accessibilityIdentifier = "LikeButton"
    }
}


