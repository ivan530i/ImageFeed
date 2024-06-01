import UIKit

final class ImagesListViewController: UIViewController {
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    private let service = ImagesListService.shared
    private let imageListService = ImagesListService.shared
    
    @IBOutlet private var tableView: UITableView!
    private var photos: [Photo] = []
    
    private let photosName: [String] = Array(0..<20).map{ "\($0)" }
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = 200
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        NotificationCenter.default.addObserver(self, selector: #selector(updateTableViewAnimated), name: ImagesListService.didChangeNotification, object: nil)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        imageListService.fetchPhotosNextPage()
    }
    
    @objc private func updateTableViewAnimated() {
            let oldCount = photos.count
            let newCount = imageListService.photos.count
            photos = imageListService.photos
            if oldCount != newCount {
                tableView.performBatchUpdates {
                    let indexPaths = (oldCount..<newCount).map { i in
                        IndexPath(row: i, section: 0)
                    }
                    tableView.insertRows(at: indexPaths, with: .automatic)
                } completion: { _ in }
            }
        }
    
    deinit {
            NotificationCenter.default.removeObserver(self)
        }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            guard
                let viewController = segue.destination as? SingleImageViewController,
                let indexPath = sender as? IndexPath,
                indexPath.row < photos.count
            else {
                assertionFailure("Invalid segue destination or indexPath out of range")
                return
            }
            
            let photo = photos[indexPath.row]
            viewController.imageUrl = URL(string: photo.largeImageURL)
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
        guard indexPath.row < photos.count else {
            return 0
        }
        
        let photo = photos[indexPath.row]
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageWidth = photo.size.width
        let scale = imageViewWidth / imageWidth
        let cellHeight = photo.size.height * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }

    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == photos.count - 1 {
            imageListService.fetchPhotosNextPage()
        }
    }
}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath) as! ImagesListCell
        configCell(for: cell, with: indexPath)
        return cell
    }
}

extension ImagesListViewController {
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        let photo = photos[indexPath.row]
        
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
        
        cell.dateLabel.text = dateFormatter.string(from: photo.createdAt ?? Date())
        
        let likeImage = photo.isLiked ? UIImage(named: "like_button_on") : UIImage(named: "like_button_off")
        cell.likeButton.setImage(likeImage, for: .normal)
    }
}


