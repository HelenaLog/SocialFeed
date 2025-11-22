import UIKit

enum FeedState {
    case loading
    case success
    case empty
    case error(String)
    case pagination(startIndex: Int, count: Int)
}

final class FeedViewController: UIViewController {
    
    // MARK: Private Properties
    
    private var viewModel: FeedViewModelProtocol
    
    private let tableView: UITableView = {
        let tableView = UITableView()
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
    
    private let errorView: ErrorView = {
        let view = ErrorView()
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let emptyView: EmptyView = {
        let view = EmptyView()
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
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
        configureUI()
        setupDelegates()
        fetchPosts()
        setupRefresh()
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
                self.set(state)
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
    
    func setupRefresh() {
        emptyView.onRefresh = { [weak self] in
            guard let self else { return }
            self.viewModel.fetchPosts()
        }
    }
    
    @objc
    func handleRefresh() {
        viewModel.refreshPosts()
    }
    
    func fetchPosts() {
        viewModel.fetchPosts()
    }
    
    func fetchAvatar(
        for cell: FeedTableViewCell,
        with post: PostViewItem
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
        guard contentHeight > viewHeight,
              targetOffsetY >= .zero
        else {
            return false
        }
        let triggerDistance = viewHeight * screensToLoadNextPage
        let remainingDistance = contentHeight - viewHeight - targetOffsetY
        
        return remainingDistance <= triggerDistance
    }
    
    func insertNewRows(startIndex: Int, count: Int) {
        guard count > .zero else { return }
        guard startIndex <= viewModel.numberOfItems() else { return }
        var indexPaths: [IndexPath] = []
        for row in startIndex..<(startIndex + count) {
            let indexPath = IndexPath(row: row, section: .zero)
            indexPaths.append(indexPath)
        }
        tableView.performBatchUpdates {
            tableView.insertRows(at: indexPaths, with: .automatic)
        }
    }
    
    func setupDelegates() {
        tableView.delegate = self
        tableView.dataSource = self
    }
}

// MARK: - UI Configuration

private extension FeedViewController {
    
    func set(_ state: FeedState) {
        switch state {
        case .success:
            activityIndicator.stopAnimating()
            tableView.isHidden = false
            errorView.isHidden = true
            emptyView.isHidden = true
            tableView.reloadData()
            if refreshControl.isRefreshing {
                refreshControl.endRefreshing()
            }
        case .empty:
            activityIndicator.stopAnimating()
            tableView.isHidden = true
            errorView.isHidden = true
            emptyView.isHidden = false
            if refreshControl.isRefreshing {
                refreshControl.endRefreshing()
            }
        case .error(let description):
            activityIndicator.stopAnimating()
            errorView.isHidden = false
            tableView.isHidden = true
            emptyView.isHidden = true
            errorView.setErrorMessage(description)
            if refreshControl.isRefreshing {
                refreshControl.endRefreshing()
            }
        case .loading:
            activityIndicator.startAnimating()
            tableView.isHidden = true
            errorView.isHidden = true
            emptyView.isHidden = true
        case .pagination(startIndex: let startIndex, count: let count):
            activityIndicator.stopAnimating()
            tableView.isHidden = false
            errorView.isHidden = true
            emptyView.isHidden = true
            insertNewRows(startIndex: startIndex, count: count)
            if refreshControl.isRefreshing {
                refreshControl.endRefreshing()
            }
        }
    }
    
    func configureUI() {
        embedViews()
        setupLayout()
        setupAppearance()
        setupRefreshControl()
    }
    
    func embedViews() {
        [
            activityIndicator,
            tableView,
            errorView,
            emptyView
        ].forEach {
            view.addSubview($0)
        }
    }
    
    func setupAppearance() {
        view.backgroundColor = .systemBackground
    }
    
    func setupRefreshControl() {
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    func setupLayout() {
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            errorView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            errorView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            errorView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            errorView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            emptyView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            emptyView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            emptyView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}
