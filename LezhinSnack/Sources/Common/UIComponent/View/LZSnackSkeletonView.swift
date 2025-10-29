import UIKit
import SkeletonView
import SnapKit

// MARK: - Skeleton Cell
public class LZSnackSkeletonCell: UICollectionViewCell {
    public static let reuseIdentifier = "SkeletonCell"
    private let containerView = UIView()
    private let imagePlaceholderView = UIView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        isSkeletonable = true
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        // Container for rounded background (optional)
        contentView.backgroundColor = .backgroundDefault
        
        // Image placeholder on left
        imagePlaceholderView.isSkeletonable = true
        imagePlaceholderView.backgroundColor = .clear
        imagePlaceholderView.layer.cornerRadius = 8
        contentView.addSubview(imagePlaceholderView)
        imagePlaceholderView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(8)
            make.leading.equalToSuperview().inset(8)
            make.bottom.equalToSuperview().inset(8)
            make.width.equalTo(imagePlaceholderView.snp.height) // square
        }
        
        // Title label on right, single line
        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor = .clear
        titleLabel.isSkeletonable = true
        titleLabel.numberOfLines = 1
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(imagePlaceholderView)
            make.leading.equalTo(imagePlaceholderView.snp.trailing).offset(12)
            make.trailing.equalToSuperview().inset(8)
            make.height.equalTo(20)
        }
        
        // Subtitle label below title, up to two lines
        subtitleLabel.font = .systemFont(ofSize: 14)
        subtitleLabel.textColor = .clear
        subtitleLabel.isSkeletonable = true
        subtitleLabel.numberOfLines = 2
        contentView.addSubview(subtitleLabel)
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.leading.trailing.equalTo(titleLabel)
            make.bottom.lessThanOrEqualToSuperview().inset(8)
        }
        
    }
}

// MARK: - Skeleton View
public class LZSnackSkeletonView: UIView {
    public var cellCount: Int = 20
    public var columns: Int = 2
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.isSkeletonable = true
        cv.dataSource = self
        cv.delegate = self
        cv.backgroundColor = .backgroundDefault
        cv.register(LZSnackSkeletonCell.self, forCellWithReuseIdentifier: LZSnackSkeletonCell.reuseIdentifier)
        return cv
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        isSkeletonable = true
        backgroundColor = .clear
        addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            
            make.top.equalToSuperview().inset(LZSConstant.HomeNavigationBarHeight)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        startSkeleton()
    }
    
    public func startSkeleton() {
        DispatchQueue.main.async {
            self.collectionView.showAnimatedGradientSkeleton()
        }
    }
    
    public func removeSkeleton() {
        collectionView.hideSkeleton(transition: .crossDissolve(0.25))
    }
}

// MARK: - UICollectionView DataSource & Skeleton DataSource

extension LZSnackSkeletonView: UICollectionViewDataSource, SkeletonCollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cellCount
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: LZSnackSkeletonCell.reuseIdentifier,
            for: indexPath
        ) as? LZSnackSkeletonCell else { return UICollectionViewCell() }
        return cell
    }
    
    public func collectionSkeletonView(_ skeletonView: UICollectionView,
                                       cellIdentifierForItemAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return LZSnackSkeletonCell.reuseIdentifier
    }

    public func collectionSkeletonView(_ skeletonView: UICollectionView,
                                       numberOfItemsInSection section: Int) -> Int {
        return cellCount
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension LZSnackSkeletonView: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView,
                               layout collectionViewLayout: UICollectionViewLayout,
                               sizeForItemAt indexPath: IndexPath) -> CGSize {
        let totalSpacing = CGFloat(columns - 1) * 8 + 32 // interItemSpacings + insets
        let width = (collectionView.bounds.width - totalSpacing) / CGFloat(columns)
        let height = width * 0.6 // e.g. 3:2
        return CGSize(width: width, height: height)
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               layout collectionViewLayout: UICollectionViewLayout,
                               insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    }
}
