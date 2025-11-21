import UIKit

enum FeedState {
    case loading
    case success
    case empty
    case error(String)
}

final class FeedViewController: UIViewController {
    
    // MARK: Private Properties

    private var viewModel: FeedViewModelProtocol
    
    private var currentState: FeedState = .loading {
        didSet {
            set(currentState)
        }
    }
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .systemPink
        tableView.showsVerticalScrollIndicator = false
        tableView.allowsSelection = false
        tableView.register(
            FeedTableViewCell.self,
            forCellReuseIdentifier: FeedTableViewCell.identifier
        )
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private let refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = .systemBlue
        refreshControl.attributedTitle = NSAttributedString(string: "Refreshing...")
        return refreshControl
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    // MARK: Init
    
    init(viewModel: FeedViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        setupBindables()
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
        setupRefreshControl()
        fetchPosts()
    }
}

// MARK: - UITableViewDelegate

extension FeedViewController: UITableViewDelegate {
    
    func scrollViewWillEndDragging(
        _ scrollView: UIScrollView,
        withVelocity velocity: CGPoint,
        targetContentOffset: UnsafeMutablePointer<CGPoint>
    ) {
        if shouldLoadNextPage(
            scrollView: scrollView,
            targetOffsetY: targetContentOffset.pointee.y,
            screensToLoadNextPage: 2.0) {
            viewModel.fetchMorePosts()
        }
    }
}

// MARK: - UITableViewDataSource

extension FeedViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfItems()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: FeedTableViewCell.identifier,
            for: indexPath
        ) as? FeedTableViewCell else {
            return UITableViewCell()
        }
        let post = viewModel.item(at: indexPath.row)
        cell.configure(with: post)
        fetchAvatar(for: cell, with: post)
        cell.onLikeButtonTapped = { [weak self] in
            guard let self else { return }
            self.viewModel.toggleLike(for: post.id, at: indexPath.row)
        }
        return cell
    }
}

// MARK: - Private Methods

private extension FeedViewController {
    
    func setupBindables() {
        viewModel.stateChanged = { [weak self] state in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.currentState = state
            }
        }
        
        viewModel.updateLikeButton = { [weak self] index, isLiked in
            guard let self else { return }
            DispatchQueue.main.async {
                let indexPath = IndexPath(row: index, section: .zero)
                if let cell = self.tableView.cellForRow(at: indexPath) as? FeedTableViewCell {
                    cell.updateLikeButton(isLiked: isLiked)
                }
            }
        }
    }
    
    func setupRefreshControl() {
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    @objc func handleRefresh() {
        viewModel.refreshPosts()
    }
    
    
    func fetchPosts() {
        viewModel.fetchPosts()
    }
    
    func fetchAvatar(
        for cell: FeedTableViewCell,
        with post: DisplayPost
    ) {
        viewModel.fetchAvatar(for: post.avatarURL) { image in
            DispatchQueue.main.async {
                cell.setAvatarImage(image)
            }
        }
    }
    
    func shouldLoadNextPage(
        scrollView: UIScrollView,
        targetOffsetY: CGFloat,
        screensToLoadNextPage: Double
    ) -> Bool {
        let viewHeight = scrollView.bounds.height
        let contentHeight = scrollView.contentSize.height
        let triggerDistance = viewHeight * screensToLoadNextPage
        let remainingDistance = contentHeight - viewHeight - targetOffsetY
        return remainingDistance <= triggerDistance
    }
    
    func embedViews() {
        [
            activityIndicator,
            tableView
        ].forEach {
            view.addSubview($0)
        }
    }
    
    func setupLayout() {
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
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
    
    func set(_ state: FeedState) {
        switch state {
        case .success:
            activityIndicator.stopAnimating()
            tableView.isHidden = false
            tableView.reloadData()
            if refreshControl.isRefreshing {
                refreshControl.endRefreshing()
            }
            
        case .empty:
            activityIndicator.stopAnimating()
            tableView.isHidden = true
            if refreshControl.isRefreshing {
                refreshControl.endRefreshing()
            }
            
        case .error(let description):
            activityIndicator.stopAnimating()
            tableView.isHidden = true
            if refreshControl.isRefreshing {
                refreshControl.endRefreshing()
            }
            
        case .loading:
            activityIndicator.startAnimating()
            tableView.isHidden = true
        }
    }
}
