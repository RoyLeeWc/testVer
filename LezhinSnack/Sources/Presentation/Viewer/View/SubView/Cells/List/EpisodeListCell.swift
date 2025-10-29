//
//  EpisodeListCell.swift
//  LezhinSnack
//
//  Created by 신진우 on 4/30/25.
//


import UIKit
import Alamofire
import SnapKit
import Lottie
import EasyTipView

protocol EpisodeListCellDelegate: AnyObject {
  func episodeListCellDidRequestTooltip(_ cell: EpisodeListCell)
}

final class EpisodeListCell: UICollectionViewCell {
    
    private var animationView: LottieAnimationView?
    
    
    weak var delegate: EpisodeListCellDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    let numberLabel: UILabel = {
        let label = UILabel()
        label.font = .pretendardSemiBold(size: 16)
        label.textColor = .white
        return label
    }()
    
    lazy var rockImageView: UIImageView = {
        let imageView = UIImageView()
        let image = UIImage(named: "ic_lock_fill")
        imageView.image = image
        imageView.backgroundColor = .clear
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    lazy var timeIconImageView: UIImageView = {
        let imageView = UIImageView()
        let image = UIImage(named: "ic_time")
        imageView.image = image
        imageView.backgroundColor = .clear
        imageView.contentMode = .scaleToFill
        
        return imageView
    }()
    
    private lazy var earlyAccessTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .pretendardMedium(size: 10)
        label.textColor = UIColor.foregroundSubtler
        label.textAlignment = .center
        label.text = "미리보기".localized
        return label
    }()
    
    private var earlyAccessGradient: CAGradientLayer?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cleanUp()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // 그라디언트가 있으면 bounds 갱신
        if let grad = earlyAccessGradient {
            grad.frame = contentView.bounds
        }
    }
    
    func cleanUp() {
        // 1) 얼리 액세스 관련 설정 제거
        earlyAccessGradient?.removeFromSuperlayer()
        earlyAccessGradient = nil
        
        timeIconImageView.removeFromSuperview()
        earlyAccessTitleLabel.removeFromSuperview()
        
        // 2) Lottie 애니메이션 뷰 제거
        animationView?.removeFromSuperview()
        animationView = nil
        
        // 3) 숫자 레이블 항상 보이도록
        numberLabel.isHidden = false
        
        // 4) 기본 락 아이콘 상태로 (configure에서 다시 세팅)
        rockImageView.isHidden = true
        
        // 5) 배경색 원복
        contentView.backgroundColor = UIColor(.fillSubtler).withAlphaComponent(0.25)
    }
    
    func configure(with entity: EpisodeListEntity) {
        numberLabel.text = "\(entity.episodeIndex)"
        if entity.isLocked {
            rockImageView.isHidden = false
        } else {
            rockImageView.isHidden = true
        }
        
        if entity.isEarlyAccess {
            setEarlyAccessView()
        }
        
        if entity.isFirstEarlyAccess {
            delegate?.episodeListCellDidRequestTooltip(self)
        }
    }
    
    private func setEarlyAccessView() {
        rockImageView.isHidden = true
        
        let grad = CAGradientLayer()
        grad.colors = [
            UIColor.fillInverseSubtle.withAlphaComponent(0.52).cgColor,
            UIColor.dimModal.withAlphaComponent(0.69).cgColor
        ]
        grad.locations = [0.50, 1.00] as [NSNumber]
        grad.startPoint = CGPoint(x: 0.5, y: 0.0)
        grad.endPoint   = CGPoint(x: 0.5, y: 1.0)
        grad.frame      = contentView.bounds
        contentView.layer.insertSublayer(grad, at: 0)
        earlyAccessGradient = grad
        
        contentView.addSubview(timeIconImageView)
        timeIconImageView.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview()
            make.size.equalTo(16)
        }
        
        contentView.addSubview(earlyAccessTitleLabel)
        earlyAccessTitleLabel.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-4)
            make.centerX.equalToSuperview()
        }
        
    }
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                // 중복 생성 방지: animationView가 없을 때만 새로 생성
                if animationView == nil {
                    let anim = LottieAnimationView(name: "ic_snack_lottie_x4")
                    anim.contentMode    = .scaleAspectFit
                    anim.loopMode       = .loop
                    anim.animationSpeed = 1.0

                    contentView.addSubview(anim)
                    anim.snp.makeConstraints { make in
                        make.center.equalToSuperview()
                        make.width.height.equalTo(24)
                    }

                    animationView = anim
                    anim.play()
                }

                contentView.backgroundColor = UIColor(.backgroundSelect)
                numberLabel.isHidden = true

            } else {
                // deselect 시 애니메이션 뷰 제거
                numberLabel.isHidden = false
                if let anim = animationView {
                    anim.removeFromSuperview()
                    animationView = nil
                }
                contentView.backgroundColor = UIColor(.fillSubtler).withAlphaComponent(0.25)
            }
        }
    }
    
    private func setupUI() {
        
        contentView.backgroundColor = UIColor(.fillSubtler).withAlphaComponent(0.25)
        contentView.roundCorners(cornerRadius: 4)
        
        
        contentView.addSubview(numberLabel)
        numberLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.equalTo(24)
        }
        
        
        contentView.addSubview(rockImageView)
        rockImageView.snp.makeConstraints { make in
            make.width.height.equalTo(14)
            make.top.trailing.equalToSuperview().inset(4)
        }
        
        
        let selectedBackgroundView = UIView()
        selectedBackgroundView.backgroundColor = UIColor(.backgroundSelect)
        selectedBackgroundView.layer.borderWidth = 1
        selectedBackgroundView.layer.borderColor = UIColor(.fillBrand).cgColor
        selectedBackgroundView.roundCorners(cornerRadius: 4)
        
        self.selectedBackgroundView = selectedBackgroundView
        
    }
    
}
