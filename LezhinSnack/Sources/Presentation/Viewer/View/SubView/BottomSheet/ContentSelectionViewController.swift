//
//  ViewerContentSelectionViewController.swift
//  LezhinSnack
//
//  Created by jinu0115 on 4/30/25.
//

import UIKit
import Tabman
import SnapKit
import Combine
import Pageboy

final class ContentSelectionViewController: TabmanViewController {
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    var subscriptions = Set<AnyCancellable>()
    
    private var viewControllers: [UIViewController] = []
    
    private let grabberView = LZSnackGrabberView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        
        view.backgroundColor = UIColor(.backgroundRaisedDefault)
        setupGrabberView()
        setupTMbar()
    }
    
    private let titleImageView: UIImageView = {
        let imageView = UIImageView()
        let image = UIImage(named: "mainBannerTitle")
        imageView.image = image
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.backgroundColor = .clear
        
        return imageView
    }()
    
    private var hidingBar: TMHidingBar!
    private let topPadding: CGFloat = 132
    
    private func setupTMbar() {
        viewControllers = makeVCs()
        
        view.addSubview(titleImageView)
        titleImageView.snp.makeConstraints { make in
            make.top.equalTo(grabberView.snp.bottom).offset(26)
            make.leading.trailing.equalToSuperview().inset(22)
            make.height.equalTo(52)
        }
        
//        // 데이터 소스 설정
        self.dataSource = self
        
        let bar = TMBar.ButtonBar()
        hidingBar = bar.hiding(trigger: .manual)
        
        bar.backgroundView.style = .clear
        // 간격 설정
        bar.layout.contentInset = UIEdgeInsets(top: topPadding,
                                               left: 16,
                                               bottom: 0,
                                               right: 16)
        
        bar.layout.contentMode = .fit
        
        // 버튼 글씨 커스텀
        bar.buttons.customize { (button) in
            button.tintColor = UIColor(.whiteOpacity35)
            button.selectedTintColor = .white
            button.font = UIFont.pretendardSemiBold(size: 16)
            button.selectedFont = UIFont.pretendardSemiBold(size: 16)
        }
        // 밑줄 쳐지는 부분
        bar.indicator.weight = .custom(value: 2)
        bar.indicator.tintColor = .white
        
        addBar(bar, dataSource: self, at: .top)
        
    }
    
    private func setupGrabberView() {
        view.addSubview(grabberView)
        grabberView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(28)
        }
    }
    
    private func makeVCs() -> [UIViewController] {
        
        guard let firstVC = AppContext.container.resolve(EpisodeListViewController.self) else {
            fatalError()
        }
        let secVC   = ContentsDetailViewController()
        let thirdVC = RelatedContentViewController()
        
        return [
            firstVC,
            secVC,
            thirdVC
        ]
    }
    
}

extension ContentSelectionViewController: PageboyViewControllerDataSource, TMBarDataSource {
    
    // Pageboy 데이터 소스 메서드
    func numberOfViewControllers(in pageboyViewController: PageboyViewController) -> Int {
        return viewControllers.count
    }
    
    func viewController(for pageboyViewController: PageboyViewController, at index: PageboyViewController.PageIndex) -> UIViewController? {
        return viewControllers[index]
    }
    
    func defaultPage(for pageboyViewController: PageboyViewController) -> PageboyViewController.Page? {
        return nil  // 기본 페이지 설정(없으면 첫번째 페이지)
    }
    
    // TMBar 데이터 소스 메서드
    func barItem(for bar: TMBar, at index: Int) -> TMBarItemable {
        
        switch index {
        case 0:
            return TMBarItem(title: "회차 정보")
        case 1:
            return TMBarItem(title: "상세정보")
        case 2:
            return TMBarItem(title: "연관 콘텐츠")
        default:
            return TMBarItem(title: "")
        }
    }
}
