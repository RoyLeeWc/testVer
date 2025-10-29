//
//  MyProfileRootNavigationBar.swift
//  LezhinSnack
//
//  Created by jinu0115 on 5/19/25.
//

import UIKit

class TitleRootNavigationBar: UIView {
    
    weak var delegate: TitleRootNavigationBarDelegate?
    
    private let titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.font = .pretendardBold(size: 20)
        titleLabel.textColor = .white
        return titleLabel
    }()
    
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
    
    let bottomBorderView: UIView = {
        let bottomBorderView = UIView()
        bottomBorderView.backgroundColor = .clear
        return bottomBorderView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        backgroundColor = .backgroundDefault
        
        self.addSubview(bottomBorderView)
        
        bottomBorderView.snp.makeConstraints { make in
            make.leading.bottom.trailing.equalToSuperview()
            make.height.equalTo(1)
        }
        
        self.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(14)
            make.leading.trailing.equalToSuperview().inset(20)
        }
    }
    
    func setupTitleText(_ text: String) {
        titleLabel.text = text
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    
    @objc private func logoButtonTapped(_ sender: UITapGestureRecognizer) {
//        delegate?.rootNavigationBarDidTapLogo(self)
    }
    
    @objc private func searchButtonTapped(_ sender: UITapGestureRecognizer) {
//        delegate?.rootNavigationBarDidTapSearch(self)
    }
    
}
