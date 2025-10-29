//
//  RootCustomNavigationBar.swift
//  BalconyShortForm
//
//  Created by 신진우 on 3/11/25.
//


import UIKit
import SnapKit

class RootNavigationBar: UIView {
    
    weak var delegate: RootNavigationBarDelegate?
    
    // 버튼 선언
    let loginButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("login".dynamicLocalized, for: .normal)
        btn.titleLabel?.textColor = .white
        return btn
    }()
    
    let searchButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("search".dynamicLocalized, for: .normal)
        btn.titleLabel?.textColor = .white
        return btn
    }()
    
    let walletButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("myWallet".dynamicLocalized, for: .normal)
        btn.titleLabel?.textColor = .white
        return btn
    }()
    
    let viewerButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("viewer".dynamicLocalized, for: .normal)
        btn.titleLabel?.textColor = .white
        return btn
    }()
    
    let borderView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray5
        return view
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
        backgroundColor = UIColor(.backgroundDefault)
        
        // UIStackView로 버튼들을 수평 배치
        let stackView = UIStackView(arrangedSubviews: [loginButton, searchButton, walletButton, viewerButton])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .center
        
        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(8)
        }
        
        addSubview(borderView)
        borderView.snp.makeConstraints { make in
            make.leading.bottom.trailing.equalToSuperview()
            make.height.equalTo(1)
        }
        
        loginButton .addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        searchButton.addTarget(self, action: #selector(searchButtonTapped), for: .touchUpInside)
        walletButton.addTarget(self, action: #selector(walletButtonTapped), for: .touchUpInside)
        viewerButton.addTarget(self, action: #selector(viewerButtonTapped), for: .touchUpInside)
    }
    
    @objc private func loginButtonTapped() {
        delegate?.rootNavigationBarDidTapLogin(self)
    }
    
    @objc private func searchButtonTapped() {
        delegate?.rootNavigationBarDidTapSearch(self)
    }
    
    @objc private func walletButtonTapped() {
        delegate?.rootNavigationBarDidTapMyWallet(self)
    }
    
    @objc private func viewerButtonTapped() {
        delegate?.rootNavigationBarDidTapViewer(self)
    }
}
