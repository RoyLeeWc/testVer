//
//  SignUpSuccessViewController.swift
//  LezhinSnack
//
//  Created by jinu0115 on 6/10/25.
//

import UIKit
import SnapKit

final class SignUpSuccessViewController: UIViewController, ChildRightCloseNavigationBarPresentable {
    
    var childNavigationBar = ChildRightCloseNavigationBar()
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let welcomeTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .pretendardBold(size: 24)
        label.textColor = UIColor(.white)
        label.textAlignment = .center
        label.numberOfLines = 0
//        label.text = "회원가입_환영_메인문구".localized
        label.text = "다양한 스낵 맛볼 준비 완료!"
        return label
    }()
    
    private let welcomeSubTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .pretendardMedium(size: 18)
        label.textColor = UIColor(.foregroundSubtler)
        label.textAlignment = .center
        label.numberOfLines = 0
//        label.text = "회원가입_환영_서브문구".localized
        label.text = "선물 받은 200코인으로 지금 바로\n첫 감상을 시작하세요!"
        return label
    }()
    
    private let welcomeImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "image"))
        imageView.contentMode = .scaleToFill
        return imageView
    }()
    
    private let welcomeGiftDescriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .pretendardMedium(size: 13)
        label.textColor = UIColor(.foregroundSubtler)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = "회원가입_혜택_타이틀".localized
        return label
    }()
    
    private var topButton: UIButton = {
        let floatingActionButton = UIButton(type: .system)
//        floatingActionButton.setTitle("회원가입완료_첫충전_버튼타이틀".localized(), for: .normal)
        floatingActionButton.setTitle("첫 충전 혜택받기", for: .normal)
        floatingActionButton.titleLabel?.font = .pretendardSemiBold(size: 16)
        floatingActionButton.backgroundColor = UIColor(.fillBrand)
        floatingActionButton.tintColor = UIColor(.white)
        floatingActionButton.layer.cornerRadius = 6
        
        return floatingActionButton
    }()
    
    private var bottomButton: UIButton = {
        let floatingActionButton = UIButton(type: .system)
//        floatingActionButton.setTitle("회원가입완료_작품탐색_버튼타이틀".localized(), for: .normal)
        floatingActionButton.setTitle("작품 탐색하기", for: .normal)
        floatingActionButton.titleLabel?.font = .pretendardSemiBold(size: 16)
        floatingActionButton.backgroundColor = .clear
        floatingActionButton.tintColor = UIColor(.white)
        floatingActionButton.layer.cornerRadius = 6
        
        return floatingActionButton
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    
    private func setupUI() {
        setupChildNavigationBar()
        childNavigationBar.titleLabel.text = ""
        childNavigationBar.delegate = self
        
        let coins = 200
        let text = "선물 받은 \(coins)코인으로 지금 바로\n첫 감상을 시작하세요!"
        let highlight = "\(coins)코인"

//        label.font = .pretendardMedium(size: 18)
//        label.textColor = UIColor(.foregroundSubtler)
//        label.textAlignment = .center
        
        //  폰트
        let font = UIFont.pretendardMedium(size: 18)
        // 기본 속성
        let attr = NSMutableAttributedString(
            string: text,
            attributes: [
                .font: font,
                .foregroundColor: UIColor(.foregroundSubtler)
            ]
        )
        // 하이라이트 적용
        if let range = text.range(of: highlight) {
            attr.addAttributes(
                [
                    .foregroundColor: UIColor(.brandRed),          // 원하는 색
                    .font: font 
                ],
                range: NSRange(range, in: text)
            )
        }

        welcomeSubTitleLabel.attributedText = attr
        welcomeSubTitleLabel.textAlignment = .center   // 가운데 정렬 유지
        welcomeSubTitleLabel.numberOfLines = 0
        
        
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        view.backgroundColor = UIColor(.backgroundDefault)
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        
        view.addSubview(bottomButton)
        bottomButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-8)
            make.height.equalTo(56)
        }
        
        view.addSubview(topButton)
        topButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(56)
            make.bottom.equalTo(bottomButton.snp.top).offset(-8)
        }
        
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(childNavigationBar.snp.bottom)
            make.leading.equalTo(view.safeAreaLayoutGuide.snp.leading)
            make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing)
            make.bottom.equalTo(topButton.snp.top).offset(-4)
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide)   // 스크롤 콘텐츠 전체
            make.width.equalTo(scrollView.frameLayoutGuide)     // 가로는 스크롤 뷰 너비와 같게
        }
        
        contentView.addSubview(welcomeTitleLabel)
        welcomeTitleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        contentView.addSubview(welcomeSubTitleLabel)
        welcomeSubTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(welcomeTitleLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        
        //TODO: 기획 쪽 회원가입 완료 관련해서 정리 된 부분이 없어서 나중에 추가 작업 예정
        welcomeImageView.contentMode = .scaleToFill
        contentView.addSubview(welcomeImageView)
        welcomeImageView.snp.makeConstraints { make in
            // 상단 위치
            make.top.equalTo(welcomeSubTitleLabel.snp.bottom).offset(64)
            // 좌우 인셋 16
            make.leading.trailing.equalToSuperview().inset(16)
            // 가로 폭에 비례한 세로 높이: (254 / 328) 배
            make.height.equalTo(welcomeImageView.snp.width).multipliedBy(959.0/1105.0)
        }
        
        
        topButton.addTarget(self, action: #selector(didTapTopButton), for: .touchUpInside)
        bottomButton.addTarget(self, action: #selector(didTapBottomButton), for: .touchUpInside)
    }
    
    @objc func didTapTopButton() {
        guard let vc = AppContext.container.resolve(InAppPurchaseViewController.self,
                                                    argument: "0" ) else { return }
        navigationController?.pushHidesBottomBarViewController(vc, animated: true)
    }
    
    @objc func didTapBottomButton() {
        navigationController?.popToRootViewController(animated: true)
    }
    
    
}

extension SignUpSuccessViewController: ChildRightCloseNavigationBarDelegate {
    
    func childNavigationBarDidTapClose(_ navigationBar: ChildRightCloseNavigationBar) {
//        navigationController?.popViewController(animated: true)
        navigationController?.popToRootViewController(animated: true)
    }
    
}

extension SignUpSuccessViewController: UIGestureRecognizerDelegate {
    
}
