//
//  PurchaseSuccessViewController.swift
//  LezhinSnack
//
//  Created by jinu0115 on 5/28/25.
//


import UIKit
import SnapKit
import SwiftyUserDefaults

final class PurchaseSuccessViewController: UIViewController, ChildRightCloseNavigationBarPresentable {
            
    var childNavigationBar = ChildRightCloseNavigationBar()
    
    private let whiteFontItems = ["결제 구분",
                                  "결제금액",
                                  "결제주기",
                                  "멤버십 구분",
                                  "충전소_결제금액_타이틀".localized,
                                  "충전소_결제주기_타이틀".localized ]
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    private let purchaseResultTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .pretendardBold(size: 24)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()
             
    private let purchaseResultSubtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .pretendardMedium(size: 18)
        label.textColor = UIColor(.foregroundSubtler)
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()
    
    private let resultContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(.backgroundRaisedDefault)
       return UIView()
    }()
    
    private let purchaseResultStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        return stackView
    }()
    
    private var floatingActionButton: UIButton = {
        let floatingActionButton = UIButton(type: .system)
        floatingActionButton.setTitle("충전성공_이어보기_버튼_타이틀".localized(), for: .normal)
        floatingActionButton.titleLabel?.font = .pretendardSemiBold(size: 16)
        floatingActionButton.backgroundColor = UIColor(.fillBrand)
        floatingActionButton.tintColor = UIColor(.white)
        floatingActionButton.layer.cornerRadius = 6
        
        return floatingActionButton
    }()
    
    let inAppPurchaseEntity: InAppPurchaseEntity
    
    init(inAppPurchaseEntity: InAppPurchaseEntity) {
        self.inAppPurchaseEntity = inAppPurchaseEntity
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError() }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    
    private func setupUI() {
        setupChildNavigationBar()
        childNavigationBar.titleLabel.text = ""
        childNavigationBar.delegate = self
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        view.backgroundColor = UIColor(.backgroundDefault)
        
        
        view.addSubview(iconImageView)
        iconImageView.snp.makeConstraints { make in
            make.top.equalTo(childNavigationBar.snp.bottom).offset(48)      // 상단 패딩 48
            make.centerX.equalToSuperview()                                 // 가로 중앙
            make.width.equalTo(view.snp.width).dividedBy(3)                 // 뷰 너비의 1/3
            make.height.equalTo(iconImageView.snp.width)                    // 1:1 비율
        }
        
        view.addSubview(floatingActionButton)
        floatingActionButton.snp.makeConstraints { make in
            make.height.equalTo(56)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-8)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        floatingActionButton.addTarget(self, action: #selector(floatButtonTapped), for: .touchUpInside)
        
        view.addSubview(resultContainerView)
        resultContainerView.snp.makeConstraints { make in
            make.bottom.equalTo(floatingActionButton.snp.top).offset(-52)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        resultContainerView.addSubview(purchaseResultStackView)
        purchaseResultStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(20)
        }
        
        view.addSubview(purchaseResultTitleLabel)
        purchaseResultTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(iconImageView.snp.bottom).offset(42)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        view.addSubview(purchaseResultSubtitleLabel)
        purchaseResultSubtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(purchaseResultTitleLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        resultContainerView.backgroundColor = UIColor(.backgroundRaisedDefault)
        resultContainerView.roundCorners(cornerRadius: 8)
        
        
        iconImageView.image = UIImage(named: "purchase_complete")
        
        setupPurchaseResultView()
        
    }
    
    @objc private func floatButtonTapped() {
        if let controllers = tabBarController?.viewControllers,
           let targetNav = controllers[safe: 0] {
            tabBarController?.selectedViewController = targetNav
            // 변경 직후에 커스텀 UI 업데이트가 필요하다면
            (tabBarController as? TabBarViewController)?
                .updateTabSelectionAppearance()
            
            if let nav = targetNav as? UINavigationController {
                nav.popToRootViewController(animated: true)
            }
        }
        
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    
    private func setupPurchaseResultView() {
        let purchaseType = inAppPurchaseEntity.inAppPurchaseType
        
        switch purchaseType {
            
        case .monthly:
            
            purchaseResultTitleLabel.text = "충전소_월간멤버십_결제완료_타이틀".localized
            purchaseResultTitleLabel.setText("충전소_월간멤버십_결제완료_타이틀".localized, highlight: "충전소_하이라이트_월간멤버십".localized, lineHeight: 34)
            
            purchaseResultSubtitleLabel.text = "충전소_멤버십_결제환영_문구".localized
            
            let details: [(label: String, value: String)] = [
                ("충전소_결제일시_타이틀".localized, inAppPurchaseEntity.purchaseDate.toStringWithGMT(regionCode: LZSUtil.getCurrentRegionCode())),
                ("충전소_결제금액_타이틀".localized, "충전소_가격기호".localized(with: inAppPurchaseEntity.amount)),
                ("충전소_결제주기_타이틀".localized, inAppPurchaseEntity.purchasePeriod ?? ""),
                ("충전소_결제수단_타이틀".localized, inAppPurchaseEntity.paymentMethod)
            ]
            
            details.forEach { item in
                let row = makeRow(label: item.label, value: item.value)
                purchaseResultStackView.addArrangedSubview(row)
            }
            
        case .annual:
            
            purchaseResultTitleLabel.setText("충전소_연간멤버십_결제완료_타이틀".localized, highlight: "충전소_하이라이트_연간멤버십".localized, lineHeight: 34)
            purchaseResultSubtitleLabel.text = "충전소_멤버십_결제환영_문구".localized
            
            let details: [(label: String, value: String)] = [
                ("충전소_결제일시_타이틀".localized, inAppPurchaseEntity.purchaseDate.toStringWithGMT(regionCode: LZSUtil.getCurrentRegionCode())),
                ("충전소_결제금액_타이틀".localized, "충전소_가격기호".localized(with: inAppPurchaseEntity.amount)),
                ("충전소_결제주기_타이틀".localized, inAppPurchaseEntity.purchasePeriod ?? ""),
                ("충전소_결제수단_타이틀".localized, inAppPurchaseEntity.paymentMethod)
            ]
            
            details.forEach { item in
                let row = makeRow(label: item.label, value: item.value)
                purchaseResultStackView.addArrangedSubview(row)
            }
            
        case .consumableCoin:
            
            purchaseResultTitleLabel.setText("충전소_코인충전_결제완료_타이틀".localized, highlight: "충전소_하이라이트_코인충전".localized, lineHeight: 34)
            purchaseResultSubtitleLabel.text = "충전소_코인충전_결제환영_문구".localized
            
            let details: [(label: String, value: String)] = [
                ("충전소_결제일시_타이틀".localized, inAppPurchaseEntity.purchaseDate.toStringWithGMT(regionCode: LZSUtil.getCurrentRegionCode())),
                ("충전소_결제금액_타이틀".localized, "충전소_가격기호".localized(with: inAppPurchaseEntity.amount)),
                ("충전소_충전코인_타이틀".localized, String(inAppPurchaseEntity.purchaseCoin ?? 0)),
                ("충전소_결제수단_타이틀".localized, inAppPurchaseEntity.paymentMethod)
            ]
            
            details.forEach { item in
                let row = makeRow(label: item.label, value: item.value)
                purchaseResultStackView.addArrangedSubview(row)
            }
        }
        
    }
    
    
    private func makeRow(label: String, value: String) -> UIStackView {
        // 1) Key 레이블
        let keyLabel = UILabel()
        keyLabel.font = .pretendardRegular(size: 14)
        keyLabel.textColor = UIColor(.foregroundSubtler)
        keyLabel.text = label
        keyLabel.setContentHuggingPriority(.required, for: .horizontal)
        
        // 2) Value 뷰 결정
        let valueView: UIView
        if label.contains("충전소_충전코인_타이틀".localized) {
            let coinView = LZSnackCoinInfoView()
            coinView.coinInfoLabel.font = .pretendardRegular(size: 14)
            coinView.setCoinText(value)
            // intrinsic size 유지
            coinView.setContentHuggingPriority(.required, for: .horizontal)
            valueView = coinView
        } else {
            let valueLabel = UILabel()
            valueLabel.font = .pretendardRegular(size: 14)
            valueLabel.textAlignment = .right
            valueLabel.text = value
            // intrinsic size 유지
            if whiteFontItems.contains(label) {
                valueLabel.textColor = UIColor(.white)
            } else {
                valueLabel.textColor = UIColor(.foregroundSubtler)
            }
            
            valueLabel.setContentHuggingPriority(.required, for: .horizontal)
            valueView = valueLabel
            
        }

        // 3) Spacer 뷰: 남은 공간을 채워서 valueView를 오른쪽 끝에 고정
        let spacer = UIView()
        spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
        spacer.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        // 4) 스택뷰에 순서대로 담기
        let row = UIStackView(arrangedSubviews: [keyLabel, spacer, valueView])
        row.axis = .horizontal
        row.alignment = .center
        row.distribution = .fill     // spacer가 남은 영역을 채우도록
        row.spacing = 8               // 키-스페이서, 스페이서-값 사이 간격
        return row
    }
    
    
}


extension PurchaseSuccessViewController: ChildRightCloseNavigationBarDelegate {
    
    func childNavigationBarDidTapClose(_ navigationBar: ChildRightCloseNavigationBar) {
        guard let navigationController = navigationController else {
            self.dismiss(animated: true)
            return
        }
        
        navigationController.popViewController(animated: true)
    }
}

extension PurchaseSuccessViewController: UIGestureRecognizerDelegate {
    
}
