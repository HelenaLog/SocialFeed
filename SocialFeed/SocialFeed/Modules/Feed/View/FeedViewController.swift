import UIKit

final class FeedViewController: UIViewController {
    
    // MARK: Private Properties
    
    private let apiService: APIServiceType
    private let storageService: StorageType
    private let imageService: ImageServiceType
    private let postService: PostServiceProtocol
    
    private var posts = [DisplayPost]()
    
    private var currentPage = 1
    private let limit = 10
    private var hasMorePosts = true
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .systemPink
        tableView.showsVerticalScrollIndicator = false
        tableView.register(
            FeedTableViewCell.self,
            forCellReuseIdentifier: FeedTableViewCell.identifier
        )
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    // MARK: Init
    
    init(
        apiService: APIServiceType,
        storageService: StorageType,
        imageService: ImageServiceType,
        postService: PostServiceProtocol
    ) {
        self.apiService = apiService
        self.storageService = storageService
        self.imageService = imageService
        self.postService = postService
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        embedViews()
        setupLayout()
        setupDelegates()
        setupAppearance()
        fetchPosts()
    }
}

// MARK: - UITableViewDelegate

extension FeedViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height
        
        if offsetY > .zero && offsetY >= (contentHeight - height) {
            guard hasMorePosts == true else { return }
            currentPage += 1
            print(currentPage)
            fetchPosts()
        }
    }
}

// MARK: - UITableViewDataSource

extension FeedViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: FeedTableViewCell.identifier,
            for: indexPath
        ) as? FeedTableViewCell else {
            return UITableViewCell()
        }
        let post = posts[indexPath.row]
        cell.configure(with: post)
        fetchAvatar(for: cell, at: indexPath, with: post.avatarURL)
        cell.onLikeButtonTapped = { [weak self] in
            guard let self else { return }
            self.posts[indexPath.row].isLiked.toggle()
            self.storageService.toggleLike(for: post.id)
        }
        return cell
    }
}

// MARK: - Private Methods

private extension FeedViewController {
    
    func fetchPosts() {
        postService.fetchPosts(page: currentPage, limit: limit) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let posts):
                self.posts.append(contentsOf: posts)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func fetchAvatar(
        for cell: FeedTableViewCell,
        at indexPath: IndexPath,
        with urlString: String
    ) {
        imageService.fetchImage(from: urlString) { result in
            switch result {
            case .success(let image):
                DispatchQueue.main.async {
                    cell.setAvatarImage(image)
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func embedViews() {
        view.addSubview(tableView)
    }
    
    func setupLayout() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    func setupAppearance() {
        view.backgroundColor = .systemBackground
    }
    
    func setupDelegates() {
        tableView.delegate = self
        tableView.dataSource = self
    }
}
