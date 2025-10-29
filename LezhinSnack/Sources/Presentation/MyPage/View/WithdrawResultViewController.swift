//
//  WithdrawResultViewController.swift
//  LezhinSnack
//
//  Created by jinu0115 on 5/22/25.
//


import UIKit
import SnapKit
import Combine

final class WithdrawResultViewController: UIViewController, ChildNavigationBarPresentable {
    
    let childNavigationBar = ChildNavigationBar()
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private let checkImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "ic_alert cheched"))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let resultTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .pretendardMedium(size: 16)
        label.textColor = .white
        label.textAlignment = .center
        label.text = "탈퇴처리 되었습니다."
        label.setLineHeight(26, alignment: .center)
        return label
    }()
    
    private let resultSubtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .pretendardRegular(size: 14)
        label.textColor = .white
        label.textAlignment = .center
        label.text = "그 동안 서비스를 이용해 주셔서 감사합니다."
        label.setLineHeight(23, alignment: .center)
        return label
    }()
    
    private let floatingActionButton: UIButton = {
        let floatingActionButton = UIButton(type: .system)
        floatingActionButton.setTitle("홈으로", for: .normal)
        floatingActionButton.titleLabel?.font = .pretendardSemiBold(size: 16)
        floatingActionButton.backgroundColor = UIColor(.fillBrand)
        floatingActionButton.tintColor = UIColor(.white)
        floatingActionButton.layer.cornerRadius = 6
        
        return floatingActionButton
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    private func setupUI() {
        view.backgroundColor = .backgroundDefault
        
        setupChildNavigationBar()
        childNavigationBar.titleLabel.text = "서비스 탈퇴"
        childNavigationBar.delegate = self
        
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        
        view.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.centerY.equalTo(view.safeAreaLayoutGuide.snp.centerY)
            make.height.equalTo(200)
        }
        
        containerView.addSubview(checkImageView)
        checkImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.size.equalTo(52)
            make.top.equalToSuperview()
        }
        
        containerView.addSubview(resultTitleLabel)
        resultTitleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(checkImageView.snp.bottom).offset(24)
        }
        
        containerView.addSubview(resultSubtitleLabel)
        resultSubtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(resultTitleLabel.snp.bottom)
            make.centerX.equalToSuperview()
        }
        
        view.addSubview(floatingActionButton)
        floatingActionButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(56)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-8)
        }
        
        floatingActionButton.addTarget(self, action: #selector(goHome), for: .touchUpInside)
    }
    
    @objc private func goHome() {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
}


extension WithdrawResultViewController: ChildNavigationBarDelegate {
    func childNavigationBarDidTapBack(_ navigationBar: ChildNavigationBar) {
        goHome()
    }
}
