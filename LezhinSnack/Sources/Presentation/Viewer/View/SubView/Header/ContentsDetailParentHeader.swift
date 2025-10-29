//
//  ContentsDetailHeader.swift
//  LezhinSnack
//
//  Created by jinu0115 on 4/30/25.
//

import UIKit
import SnapKit


//height160
final class ContentsDetailParentHeader: UICollectionReusableView {
    private let promotionView = LZSnackPromotionView(
        type: .allCases.randomElement()!
    )
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageStackView.subviews.forEach { $0.removeFromSuperview() }
        
    }
    
    private let imageStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal                // 가로 축
        stackView.spacing = 4                        // 아이템 간 간격 4pt
        stackView.alignment = .center                // 수직으로 가운데 정렬
        stackView.distribution = .fill               // 컨텐츠 크기만큼 채움 → 왼쪽부터 순서대로 배치
        // 가로로 콘텐츠 크기만큼만 늘어나게
        stackView.setContentHuggingPriority(.required, for: .horizontal)
        return stackView
    }()

    
    let headerTitle: UILabel = {
        let label = UILabel()
        label.backgroundColor = .clear
        label.textColor = .white
        label.font = .pretendardMedium(size: 14)
        return label
    }()
    
    let headerSubTitle: UILabel = {
        let label = UILabel()
        label.backgroundColor = .clear
        label.textColor = .white
        label.font = .pretendardRegular(size: 13)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func setupUI() {
        self.backgroundColor = UIColor(.clear)
        
        
        addSubview(promotionView)
        promotionView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalToSuperview().inset(32)
            make.height.equalTo(20)
        }
        
        addSubview(headerTitle)
        headerTitle.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(promotionView.snp.bottom).offset(8)
        }
        
        
        addSubview(headerSubTitle)
        headerSubTitle.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(headerTitle.snp.bottom).offset(28)
            make.height.equalTo(18)
        }
        
        addSubview(imageStackView)
        imageStackView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.height.equalTo(24)
            make.top.equalTo(headerSubTitle.snp.bottom).offset(10)
        }
        
    }
    
    func addImageToStack(_ image: UIImage) {
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.widthAnchor.constraint(equalToConstant: 24).isActive = true
        imageStackView.addArrangedSubview(imageView)
    }

    // 추가: 이미지 배열 단위로 한 번에 추가
    func addImagesToStack(_ images: [UIImage]) {
        images.forEach { image in
            addImageToStack(image)
        }
    }
    
}
