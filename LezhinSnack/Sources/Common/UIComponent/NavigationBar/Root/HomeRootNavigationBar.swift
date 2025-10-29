//
//  RootCustomNavigationBar.swift
//  BalconyShortForm
//
//  Created by 신진우 on 3/11/25.
//


import UIKit
import SnapKit

class HomeRootNavigationBar: UIView {
    
    weak var delegate: HomeRootNavigationBarDelegate?
    
    private let gradientLayer = CAGradientLayer()
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        // 기본 hitTest를 호출하여 터치가 닿은 뷰를 확인합니다.
        let hitView = super.hitTest(point, with: event)
        // 만약 터치 대상이 자신(self)라면, nil을 반환하여 이벤트를 무시합니다.
        if hitView === self {
            return nil
        }
        // 그렇지 않으면 하위 뷰(hitView)가 있다면 그 뷰를 반환합니다.
        return hitView
    }
    
    let logoImageView: UIImageView = {
        let logoImageView = UIImageView()
        
        logoImageView.image = UIImage(named: "LogoType")
        logoImageView.contentMode = .scaleAspectFit
        return logoImageView
    }()
    
    
    let searchIconImageView: UIImageView = {
        let searchIconImageView = UIImageView()
        searchIconImageView.image = UIImage(named: "ic_search")
        searchIconImageView.contentMode = .scaleAspectFit
        
        return searchIconImageView
    }()
    
    let bottomBorderView: UIView = {
        let bottomBorderView = UIView()
        bottomBorderView.backgroundColor = .clear
        return bottomBorderView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupGradient()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        setupGradient()
    }
    
    private func setupView() {
        backgroundColor = .clear
        
        self.addSubview(logoImageView)
        self.addSubview(searchIconImageView)
        self.addSubview(bottomBorderView)
        
        
        logoImageView.snp.makeConstraints { make in
            make.top.equalTo(self.safeAreaLayoutGuide.snp.top).inset(18)
            make.leading.equalTo(self.snp.leading).inset(20)
            make.bottom.equalTo(self.snp.bottom).inset(18)
        }
        
        searchIconImageView.snp.makeConstraints { make in
            make.top.equalTo(self.safeAreaLayoutGuide.snp.top).inset(8)
            make.trailing.equalTo(self.snp.trailing).inset(12)
            make.bottom.equalTo(self.snp.bottom).inset(8)
        }
        
        
        searchIconImageView.isUserInteractionEnabled = true
        let searchTap = UITapGestureRecognizer(target: self, action: #selector(searchButtonTapped(_:)))
        searchIconImageView.addGestureRecognizer(searchTap)
        
        logoImageView.isUserInteractionEnabled = true
        let logoTap = UITapGestureRecognizer(target: self, action: #selector(logoButtonTapped(_:)))
        logoImageView.addGestureRecognizer(logoTap)
        
        
        bottomBorderView.snp.makeConstraints { make in
            make.leading.bottom.trailing.equalToSuperview()
            make.height.equalTo(1)
        }
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // 뷰 크기가 바뀔 때마다 그라디언트 레이어 크기 업데이트
        gradientLayer.frame = bounds
    }
    
    private func setupGradient() {
        let opaqueColor      = UIColor(.blackOpacity72)
        let transparentColor = opaqueColor.withAlphaComponent(0.0)

        // 상단(0.0)에는 불투명, 하단(1.0)에는 투명
        gradientLayer.colors = [
            opaqueColor.cgColor,       // y = 0.0 (top)
            transparentColor.cgColor   // y = 1.0 (bottom)
        ]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint   = CGPoint(x: 0.5, y: 1.0)

        layer.insertSublayer(gradientLayer, at: 0)
    }
    
    func applySolidBackground() {
        guard backgroundColor != UIColor(.backgroundDefault) else { return }
        gradientLayer.isHidden = true                 // 그라디언트 숨김
        backgroundColor = UIColor(.backgroundDefault) // 불투명 색상
        bottomBorderView.backgroundColor = UIColor(.borderSubtler)
    }

    func applyGradientBackground() {
        guard gradientLayer.isHidden else { return }
        gradientLayer.isHidden = false    // 그라디언트 다시 보이게
        backgroundColor = .clear          // 투명(그래야 레이어가 보임)
        bottomBorderView.backgroundColor = .clear
    }
    
    
    @objc private func logoButtonTapped(_ sender: UITapGestureRecognizer) {
        delegate?.rootNavigationBarDidTapLogo(self)
    }
    
    @objc private func searchButtonTapped(_ sender: UITapGestureRecognizer) {
        delegate?.rootNavigationBarDidTapSearch(self)
    }
    
}
