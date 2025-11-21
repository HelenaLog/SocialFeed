import UIKit

final class ErrorView: UIView {
    
    // MARK: Callback
    
    var onRetry: (() -> Void)?
    
    // MARK: Private Properties
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: StringConstants.Icon.exclamationmark)
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .blue
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = StringConstants.Title.title
        label.font = UIFont.boldSystemFont(ofSize: PointConstants.Font.titleSize)
        label.textAlignment = .center
        label.numberOfLines = .zero
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.text = StringConstants.Title.message
        label.font = UIFont.systemFont(ofSize: PointConstants.Font.messageSize)
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.numberOfLines = .zero
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(StringConstants.Button.title, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: PointConstants.Font.buttonSize)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .blue
        button.layer.cornerRadius = PointConstants.Button.cornerRadius
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        embedViews()
        setupBehavior()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public Methods

extension ErrorView {
    func setErrorMessage(_ message: String) {
        messageLabel.text = message
    }
}

// MARK: - Private Methods

private extension ErrorView {
    
    @objc func retryButtonTapped() {
        onRetry?()
    }
    
    func setupBehavior() {
        actionButton.addTarget(
            self,
            action: #selector(retryButtonTapped),
            for: .touchUpInside
        )
    }
    
    func embedViews() {
        [
            imageView,
            titleLabel,
            messageLabel,
            actionButton
        ].forEach { addSubview($0) }
    }
    
    func setupLayout() {
        NSLayoutConstraint.activate([
            imageView.heightAnchor.constraint(equalToConstant: PointConstants.Image.height),
            imageView.widthAnchor.constraint(equalToConstant: PointConstants.Image.height),
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -PointConstants.Spacing.imageCenterYOffset),
            
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: PointConstants.Spacing.titleTop),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: PointConstants.Spacing.leading),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: PointConstants.Spacing.trailing),
            
            messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: PointConstants.Spacing.subtitleTop),
            messageLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: PointConstants.Spacing.leading),
            messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: PointConstants.Spacing.trailing),
            
            actionButton.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: PointConstants.Spacing.buttonTop),
            actionButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            actionButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: PointConstants.Spacing.buttonLeading),
            actionButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: PointConstants.Spacing.buttonTrailing),
            actionButton.heightAnchor.constraint(equalToConstant: PointConstants.Button.height)
        ])
    }
}

// MARK: - Constants

private extension ErrorView {
    
    // MARK: PointConstants
    
    enum PointConstants {
        
        // MARK: Font
        
        enum Font {
            static let titleSize: CGFloat = 28
            static let messageSize: CGFloat = 16
            static let buttonSize: CGFloat = 18
        }
        
        // MARK: Spacing
        
        enum Spacing {
            static let leading: CGFloat = 24
            static let trailing: CGFloat = -24
            static let buttonLeading: CGFloat = 16
            static let buttonTrailing: CGFloat = -16
            static let titleTop: CGFloat = 24
            static let subtitleTop: CGFloat = 12
            static let buttonTop: CGFloat = 24
            static let imageCenterYOffset: CGFloat = -45
        }
        
        // MARK: Image
        
        enum Image {
            static let height: CGFloat = 150
        }
        
        // MARK: Button
        
        enum Button {
            static let height: CGFloat = 45
            static let cornerRadius: CGFloat = 10
        }
    }
    
    // MARK: StringConstants
    
    enum StringConstants {
        
        enum Title {
            static let title = "Oops, something went wrong"
            static let message = "We’ve encountered an unexpected error. Please try again."
        }
        
        enum Icon {
            static let exclamationmark = "exclamationmark.triangle.fill"
        }
        
        enum Button {
            static let title = "Повторить"
        }
    }
}
