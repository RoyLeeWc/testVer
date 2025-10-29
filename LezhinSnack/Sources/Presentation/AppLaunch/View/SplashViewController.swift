//
//  SplashViewController.swift
//  BalconyShortForm
//
//  Created by jinu0115 on 3/4/25.
//

import UIKit
import Lottie
import Combine
import SwiftyUserDefaults

protocol SplashViewControllerDelegate: AnyObject {
    func failForServiceUnavailable()
    func successLoad()
}

class SplashViewController: UIViewController {
    
    
    private let viewModel: SplashViewModel
    
    weak var delegate: SplashViewControllerDelegate?
    
    var animationView: LottieAnimationView?
    var subscriptions = Set<AnyCancellable>()
    
    init?(viewModel: SplashViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bind()
        
        viewModel.requestLogin()
        
    }
    
    private func bind() {
        viewModel.$isLoginProcessOver
            .receive(on: RunLoop.main)
            .sink { [weak self] isLoginProcessOver in
                if isLoginProcessOver == true {
                    if let animationView = self?.animationView {
                        animationView.play { [weak self] _ in
//                            self?.showNetworkErrorPopup()
//                            self?.showRequisiteUpdatePopup()
//                            self?.showOptionalUpdatePopup()
//                            self?.showSystemMaintenancePopup()
//                            self?.showAppPermissionPopup()
                            self?.delegate?.successLoad()
                        }
                    } else {
                        self?.delegate?.successLoad()
                    }
                }
            }.store(in: &subscriptions)
    }
    
    private func showNetworkErrorPopup() {
        onMain { [weak self] in
            let popup = LZSnackAlertPopupView(
                width: 320,
                height: 222,
                title: "네트워크 연결 오류",
                message: "인터넷 연결이 끊어졌습니다. 연결을 확인한 후 다시 시도해 주세요.",
                buttonTitle: "다시 시도하기",
                handler: { self?.delegate?.successLoad() },
                showsCloseButton: true,
                closeHandler: { self?.delegate?.successLoad() }
            )
            popup.show()
        }
    }
    
    private func showRequisiteUpdatePopup() {
        onMain { [weak self] in
            let popup = LZSnackAlertPopupView(
                width: 320,
                height: 222,
                title: "필수 업데이트가 있습니다.",
                message: "안정적인 서비스 사용을 위해 최신 버전으로 업데이트 해주세요.",
                buttonTitle: "업데이트 하기",
                handler: { self?.delegate?.successLoad() },
                showsCloseButton: true,
                closeHandler: { self?.showRequisiteUpdatePopup() }
            )
            popup.show()
        }
    }
    
    private func showSystemMaintenancePopup() {
        onMain { [weak self] in
            let popup = LZSnackAlertPopupView(
                width: 320,
                height: 222,
                title: "시스템 점검 안내",
                message: "보다 안정적인 서비스를 제공하기 위해 시스템을 점검하고 있습니다. 점검 기간 동안 서비스 이용이 일시적으로 중단되오니 양해 부탁드립니다.",
                buttonTitle: "확인",
                handler: { self?.delegate?.successLoad() },
                showsCloseButton: true,
                closeHandler: { self?.showRequisiteUpdatePopup() }
            )
            popup.show()
        }
    }
    
    
    private func showOptionalUpdatePopup() {
        onMain { [weak self] in
            let popup = LZSnackAlertPopupView(
                width: 320,
                height: 242,
                title: "권장 업데이트가 있습니다.",
                message: "더 나은 서비스 사용을 위해 최신 버전으로 업데이트 해주세요.",
                leftButtonTitle: "다음에 하기",
                leftHandler: {
                    self?.delegate?.successLoad()
                },
                rightButtonTitle: "업데이트 하기",
                rightHandler: { [weak self] in
                    self?.delegate?.successLoad()
                },
                showsCloseButton: true,
                closeHandler: { self?.showOptionalUpdatePopup() }
            )
            popup.show()
        }
    }
    
    private func showAppPermissionPopup() {
        onMain { [weak self] in
            let popup = LZSnackAppPermissionPopup (
                width: 320,
                height: 442,
                buttonTitle: "확인",
                handler: { self?.delegate?.successLoad() }
            )
            popup.show()
        }
    }
    
    
    
    private func setupUI() {
        self.animationView = LottieAnimationView.init(name: "splash_fin")
        if let animationView {
            self.view.backgroundColor = UIColor(.fillBrand)
            
            animationView.contentMode = .scaleAspectFit
            animationView.loopMode = .repeat(1)
            animationView.animationSpeed = 1.0
            self.view.addSubview(animationView)
            animationView.snp.makeConstraints { make in
                make.center.equalToSuperview()
                make.width.height.equalTo(220)
            }
        } else {
            self.delegate?.successLoad()
        }
    }
    
    func versionCheckProc() {
        
    }
    
    func moveToMainPage() {
        
    }
    
}
