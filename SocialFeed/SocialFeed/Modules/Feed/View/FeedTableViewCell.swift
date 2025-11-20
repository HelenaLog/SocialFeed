import UIKit

final class FeedTableViewCell: UITableViewCell {
    
    // MARK: Static Properties
    
    static let identifier = StringConstants.identifier
    
    // MARK: Private Properties
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: PointConstants.Font.title)
        label.numberOfLines = .zero
        label.textAlignment = .justified
        label.lineBreakMode = .byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let bodyLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: PointConstants.Font.body)
        label.numberOfLines = .zero
        label.textAlignment = .justified
        label.lineBreakMode = .byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.tintColor = .systemGray2
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let likeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: StringConstants.heartIcon), for: .normal)
        button.setImage(UIImage(systemName: StringConstants.heartFillIcon), for: .selected)
        button.tintColor = .systemRed
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        embedViews()
        setupLayout()
        setupAppearance()
        setupBehavior()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Lifecycle
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        bodyLabel.text = nil
        avatarImageView.image = nil
        likeButton.isSelected = false
    }
}

// MARK: - Public Methods

extension FeedTableViewCell {
    
    func configure(with item: PostDTO) {
        titleLabel.text = item.title
        bodyLabel.text = item.body
        likeButton.isSelected = true
        avatarImageView.image = UIImage(systemName: StringConstants.personFillIcon)
    }
}

// MARK: - Private Methods

private extension FeedTableViewCell {
    func embedViews() {
        [
            titleLabel,
            bodyLabel,
            avatarImageView,
            likeButton
        ].forEach { contentView.addSubview($0) }
    }
    
    func setupLayout() {
        NSLayoutConstraint.activate([
            avatarImageView.topAnchor.constraint(
                equalTo: contentView.topAnchor,
                constant: PointConstants.Layout.top
            ),
            avatarImageView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: PointConstants.Layout.leading
            ),
            avatarImageView.heightAnchor.constraint(equalToConstant: PointConstants.Avatar.size),
            avatarImageView.widthAnchor.constraint(equalToConstant: PointConstants.Avatar.size),
            
            titleLabel.topAnchor.constraint(
                equalTo: avatarImageView.bottomAnchor,
                constant: PointConstants.Layout.spacing
            ),
            titleLabel.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: PointConstants.Layout.leading
            ),
            titleLabel.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: PointConstants.Layout.trailing
            ),
            
            bodyLabel.topAnchor.constraint(
                equalTo: titleLabel.bottomAnchor,
                constant: PointConstants.Layout.spacing
            ),
            bodyLabel.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: PointConstants.Layout.leading
            ),
            bodyLabel.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: PointConstants.Layout.trailing
            ),
            
            likeButton.topAnchor.constraint(
                equalTo: bodyLabel.bottomAnchor,
                constant: PointConstants.Layout.spacing
            ),
            likeButton.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: PointConstants.Layout.leading
            ),
            likeButton.widthAnchor.constraint(equalToConstant: PointConstants.Button.size),
            likeButton.heightAnchor.constraint(equalToConstant: PointConstants.Button.size),
            likeButton.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor,
                constant: PointConstants.Layout.bottom
            )
        ])
    }
    
    func setupAppearance() {
        avatarImageView.layer.cornerRadius = bounds.height / PointConstants.Avatar.divider
    }
    
    func setupBehavior() {
        likeButton.addTarget(self, action:  #selector(likeTapped), for: .touchUpInside)
    }
    
    @objc
    func likeTapped() {
        likeButton.isSelected.toggle()
    }
}

// MARK: - Constants

private extension FeedTableViewCell {
    
    // MARK: PointConstants
    
    enum PointConstants {
        
        // MARK: Layout
        
        enum Layout {
            static let spacing: CGFloat = 8
            static let top: CGFloat = 16
            static let leading: CGFloat = 16
            static let trailing: CGFloat = -16
            static let bottom: CGFloat = -16
        }
        
        // MARK: Avatar
        
        enum Avatar {
            static let size: CGFloat = 45
            static let divider: CGFloat = 2
        }
        
        // MARK: Button
        
        enum Button {
            static let size: CGFloat = 30
        }
        
        // MARK: Font
        
        enum Font {
            static let title: CGFloat = 17
            static let body: CGFloat = 15
        }
    }
    
    // MARK: StringConstants
    
    enum StringConstants {
        static let identifier = "FeedTableViewCell"
        static let heartIcon = "heart"
        static let heartFillIcon = "heart.fill"
        static let personFillIcon = "person.circle"
    }
}
