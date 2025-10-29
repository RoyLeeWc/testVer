//
//  LoadingView.swift
//  LezhinSnack
//
//  Created by jinu0115 on 6/2/25.
//
import UIKit
import SnapKit
import Lottie


final class LZSnackLoadingView: UIView {
    // MARK: - 프로퍼티
    private let animationView: LottieAnimationView = {
        // "loading"은 프로젝트에 포함된 JSON 파일 이름 (확장자 제외)
        let anim = LottieAnimationView(name: "loadingSpinner")
        anim.loopMode = .loop
        anim.contentMode = .scaleAspectFit
        return anim
    }()

    // 반투명 배경을 위한 뷰
    private let backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0, alpha: 0.4)
        return view
    }()

    // MARK: - init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayout()
    }

    private func setupLayout() {
        // 1) 반투명 배경 깔기
        addSubview(backgroundView)
        backgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        // 2) 애니메이션 뷰 중앙 배치
        addSubview(animationView)
        animationView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            // 가로/세로 크기: 화면 너비의 20~25% 정도 권장
            make.width.height.equalToSuperview().multipliedBy(0.2)
        }
    }

    // MARK: - 외부에서 호출할 API
    func startAnimating() {
        animationView.play()
    }

    func stopAnimating() {
        animationView.stop()
    }
}
