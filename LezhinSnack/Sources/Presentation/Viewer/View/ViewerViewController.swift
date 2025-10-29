import UIKit
import SnapKit
import Combine
import AVFoundation
import AVKit

final class ViewerViewController: UIViewController {
    
    
    deinit {
        printX("메모리 해제")
        for case let cell as VideoPlayableCell in collectionView.visibleCells {
            cell.cleanUp()
        }
    }
    
    private let currentViewerType: ViewerType
    
    private var isCurrentViewDidDisappear: Bool = false
    
    private var subscriptions = Set<AnyCancellable>()
    
    // 섹션 타입 정의 (여기서는 하나의 섹션만 사용)
    enum Section {
        case main
        case promotion
        case tasted
    }
    
    // 셀 식별을 위한 데이터 모델
    struct VideoItem: Hashable {
        let id = UUID()
        // 추후 필요한 속성을 추가할 수 있습니다.
    }
    
    // 타입별 더미 데이터
    private var mainItems: [VideoItem]      { (0..<10).map { _ in VideoItem() } }
    private var promotionItems: [VideoItem] { (0..<5).map  { _ in VideoItem() } }
    private var tastedItems: [VideoItem]    { (0..<8).map  { _ in VideoItem() } }
    
    init(viewerType: ViewerType) {
        self.currentViewerType = viewerType
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = UIColor(.backgroundDefault)
        return collectionView
    }()
    
    private var dataSource: UICollectionViewDiffableDataSource<Section, VideoItem>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        bind()
        
        collectionView.makeSecure()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // 스크롤이 멈춘 것처럼 처리해서 초기 셀 재생
        scrollViewDidEndDecelerating(collectionView)
        isCurrentViewDidDisappear = false
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        for case let cell as VideoPlayableCell in collectionView.visibleCells {
            cell.pausePlayer()
        }
        isCurrentViewDidDisappear = true
    }
    
//    override func viewDidDisappear(_ animated: Bool) {
//        super.viewDidDisappear(animated)
//        
//        for case let cell as VideoPlayableCell in collectionView.visibleCells {
//            cell.pausePlayer()
//        }
//    }
    
    func setupUI() {
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        view.backgroundColor = UIColor(.backgroundDefault)
        setupCollectionView()
        configureDataSource()
        applySnapshot()
    }
    
    private func bind() {
        NotificationCenter.default.publisher(for: .LZSChangeEpisodeReceiveNotification)
            .compactMap { notification in notification.object as? Int }
            .receive(on: RunLoop.main)
            .sink { [weak self] episodeIndex in
                guard let self = self else { return }
                
                // 1) 스냅샷에서 전체 아이템 수 가져오기
                let totalItems = self.dataSource.snapshot().itemIdentifiers.count
                
                // 2) 유효성 검사
                guard episodeIndex >= 0, episodeIndex < totalItems else { return }
                
                // 3) 실제 스크롤할 인덱스 경로 생성
                //    (뷰어는 항상 한 섹션만 사용하니 section 0)
                let indexPath = IndexPath(item: episodeIndex, section: 0)
                
                // 4) 안전하게 스크롤
                self.collectionView.scrollToItem(
                    at: indexPath,
                    at: .centeredHorizontally,
                    animated: true
                )
            }
            .store(in: &subscriptions)
        
        NotificationCenter.default.publisher(for: .LZSPurchaseEpisodeReceiveNotification)
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                guard let self = self, let vc = AppContext.container.resolve(IAPBottomSheetViewController.self,
                                                                             argument: "0" ) else { return }
                vc.delegate = self
                presentBottomSheet(vc,isSmallDetent: false)
            }.store(in: &subscriptions)
        
        NotificationCenter.default.publisher(for: .LZSEarlyAccessReceiveNotification)
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                
            }.store(in: &subscriptions)
        
        NotificationCenter.default.publisher(for: UIApplication.userDidTakeScreenshotNotification)
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.popupWaringAlert()
            }
            .store(in: &subscriptions)
        
        NotificationCenter.default.publisher(for: UIScreen.capturedDidChangeNotification)
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                // UIScreen.capturedDidChangeNotification은 녹화 시작·종료 둘 다 전달됨
                if UIScreen.main.isCaptured {
                    self?.popupWaringAlert()
                }
            }
            .store(in: &subscriptions)
        
    }
    
    func setupCollectionView() {
        // 컴포지셔널 레이아웃: 셀 하나가 전체 화면을 차지하도록 구성
        
        
        //collectionView.collectionViewLayout = createLayout()
        //collectionView.backgroundColor = .clear
        
        // 전체 화면 셀 등록
        //collectionView.register(TestVideoCell.self)
        collectionView.register(MainVideoCell.self)
        collectionView.register(TastedVideoCell.self)
        collectionView.register(PromotionVideoCell.self)
        
        
        collectionView.delegate = self
        collectionView.isPagingEnabled = true
        
        
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalTo(self.view.safeAreaLayoutGuide.snp.edges)
        }
        
    }
    
    func createLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, layoutEnvironment -> NSCollectionLayoutSection? in
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                  heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                   heightDimension: .fractionalHeight(1.0))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            
            let section = NSCollectionLayoutSection(group: group)
            
            return section
        }
        return layout
    }
    
    private func applySnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, VideoItem>()

        switch currentViewerType {
        case .mainViewer:
            snapshot.appendSections([.main])
            snapshot.appendItems(mainItems, toSection: .main)

        case .promotionViewer:
            snapshot.appendSections([.promotion])
            snapshot.appendItems(promotionItems, toSection: .promotion)

        case .tastedViewer:
            snapshot.appendSections([.tasted])
            snapshot.appendItems(tastedItems, toSection: .tasted)
        }

        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, VideoItem>(
            collectionView: collectionView
        ) { [weak self] collectionView, indexPath, videoItem in
            guard let self = self else { return UICollectionViewCell() }

            switch self.currentViewerType {
            case .mainViewer:
                guard let cell = collectionView.dequeueReusableCell( withReuseIdentifier: MainVideoCell.reuseIdentifier, for: indexPath ) as? MainVideoCell else { return UICollectionViewCell() }
                //cell.configure()
                cell.delegate = self
                return cell

            case .promotionViewer:
                guard let cell = collectionView.dequeueReusableCell( withReuseIdentifier: PromotionVideoCell.reuseIdentifier, for: indexPath ) as? PromotionVideoCell else { return UICollectionViewCell() }
                //cell.configure()
                return cell

            case .tastedViewer:
                guard let cell = collectionView.dequeueReusableCell( withReuseIdentifier: TastedVideoCell.reuseIdentifier, for: indexPath ) as? TastedVideoCell else { return UICollectionViewCell() }
                //cell.configure()
                cell.delegate = self
                return cell
            }
        }
    }
    
    @objc private func popupWaringAlert() {
        if isCurrentViewDidDisappear { return }
        onMain {
            let popup = LZSnackAlertPopupView(
                width: 320,
                height: 242,
                title: "스크린샷이 감지되었어요.",
                message: "저작권 보호를 위해 캡쳐·녹화·미러링은 제한됩니다.\n무단 녹화 및 공유 시 법적 제재를 받을 수 있으니\n유의해주세요.",
                buttonTitle: "확인",
                handler: { /*…*/ }
            )
            popup.show()
        }
    }
    
    @objc private func popupWaringToast() {
        DispatchQueue.main.async {
            var captureSecureMessage = "[다국어처리요망] 스크린캡쳐 감지"
            
            self.view.makeToast(captureSecureMessage, duration: 3.0, position: .center, style:LZSUtil.makeShortFormToastStyle())
            
        }
    }
}

extension ViewerViewController: UICollectionViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        // 1) 화면의 모든 VideoPlayableCell 일시정지
        for case let cell as VideoPlayableCell in collectionView.visibleCells {
            cell.pausePlayer()
        }
        // 2) 중앙 셀 찾아서 재생
        let center = view.convert(collectionView.center, to: collectionView)
        if let indexPath = collectionView.indexPathForItem(at: center),
           let cell = collectionView.cellForItem(at: indexPath) as? VideoPlayableCell {
            cell.playPlayer()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        // 화면에 나타나는 모든 VideoPlayableCell 구성
        (cell as? VideoPlayableCell)?.configure()
        print("셀 \(indexPath) 화면에 나타나 configure 호출")
    }

    func collectionView(_ collectionView: UICollectionView,
                        didEndDisplaying cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        // 화면에서 사라지는 모든 VideoPlayableCell 정리
        (cell as? VideoPlayableCell)?.cleanUp()
        print("셀 \(indexPath) 화면에서 사라져 cleanUp 호출")
    }
}

extension ViewerViewController: UIGestureRecognizerDelegate { }


extension ViewerViewController: VideoPlayableCellDelegate {
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        // deceleration 끝난 것처럼 처리
        scrollViewDidEndDecelerating(scrollView)
    }
    
//    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
//        if !decelerate {
//            scrollViewDidEndDecelerating(scrollView)
//        }
//    }
    
    func videoCellDidTapLikeButton(_ cell: any VideoPlayableCell) {
        switch cell {
        case is MainVideoCell:
            guard let cell = cell as? MainVideoCell else { return }
            cell.isLikeEpisode.toggle()
        case is TastedVideoCell:
            guard let cell = cell as? TastedVideoCell else { return }
            cell.isLikeEpisode.toggle()
        default: break
        }
    }
    
    func videoCellDidTapWishButton(_ cell: any VideoPlayableCell) {
        switch cell {
        case is MainVideoCell:
            guard let cell = cell as? MainVideoCell else { return }
            cell.isWishedEpisode.toggle()
            toastWhenListViewAddOrDelete(cell.isWishedEpisode)
        case is TastedVideoCell:
            guard let cell = cell as? TastedVideoCell else { return }
            cell.isWishedEpisode.toggle()
            toastWhenListViewAddOrDelete(cell.isWishedEpisode)
        default: break
        }
    }
    
    func toastWhenListViewAddOrDelete(_ isWished: Bool) {
        // 1) 메시지와 아이콘 표시 여부를 분기
        let message = isWished ? "내 목록에서 추가 되었습니다." : "삭제가 완료되었습니다."
        let showsIcon = isWished
        
        let toastView = LZSnackToastView(text: message, showsIcon: showsIcon)
        LZSnackToastHelper.showOnce(on: view, toast: toastView, duration: 2.0)
    }
    
    func videoCellDidTapShareButton(_ cell: any VideoPlayableCell) {
        switch cell {
        case is MainVideoCell:
            let vc = RecommendViewController()
            
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true)
            
        case is TastedVideoCell:
            guard let vc = AppContext.container.resolve(IAPBottomSheetViewController.self,
                                                        argument: "0" ) else { return }
            vc.delegate = self
            presentBottomSheet(vc,isSmallDetent: false)
        default: break
        }
    }
    
    func videoCell(_ cell: any VideoPlayableCell, didTapSpeedButton button: UIButton, playbackRates: [Float]) {
        guard let cell = cell as? MainVideoCell else { return }
        let speedVC = SpeedSelectionViewController(
            playbackRates: playbackRates,
            selectedRate: cell.currentPlaybackRate
        )
        speedVC.selectionHandler = { [weak cell] rate in
            guard let cell = cell else { return }
            cell.currentPlaybackRate = rate
            cell.speedButton.setTitle(String(format: "%.1fx", rate), for: .normal)
            
            switch cell.player?.timeControlStatus {
            case .playing:
                cell.player?.rate = rate
            case .paused, .waitingToPlayAtSpecifiedRate, nil ,.some(_):
                cell.playPlayer()
            }
        }
        presentBottomSheet(speedVC)
    }
    
    func videoCell(_ cell: any VideoPlayableCell, didTapSubtitleButton button: UIButton, availableOptions: [AVMediaSelectionOption]) {
        guard let cell = cell as? MainVideoCell else { return }
        let currentOption = cell.playerItem?.asset
            .mediaSelectionGroup(forMediaCharacteristic: .legible)
            .flatMap { group in cell.playerItem?.selectedMediaOption(in: group) }
        let subtitleVC = SubtitleSelectionViewController(
            options: availableOptions,
            selectedOption: currentOption
        )
        subtitleVC.selectionHandler = { [weak cell] option in
            guard let cell = cell,
                  let group = cell.playerItem?.asset.mediaSelectionGroup(forMediaCharacteristic: .legible) else { return }
            cell.playerItem?.select(option, in: group)
        }
        presentBottomSheet(subtitleVC)
    }
    
    func videoCellDidFinishPlayback(_ cell: any VideoPlayableCell) {
        guard let cell = cell as? UICollectionViewCell,
              let idx = collectionView.indexPath(for: cell ) else { return }
        
        let next = IndexPath(item: idx.item + 1, section: idx.section)
        guard next.item < dataSource.snapshot().numberOfItems else { return }
        // 스크롤 애니메이션 시작
        collectionView.scrollToItem(at: next, at: .centeredHorizontally, animated: true)
    }
    
    func videoCellDidTapBack(_ cell: any VideoPlayableCell) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func presentBottomSheet(_ vc: UIViewController, isSmallDetent: Bool = true) {
        if let existing = presentedViewController {
            // 이미 모달이 떠 있으면 애니메이션 없이 닫고, 닫힌 후에 새로 표시
            existing.dismiss(animated: false) {
                self.configureAndPresentBottomSheet(vc, isSmallDetent: isSmallDetent)
            }
        } else {
            configureAndPresentBottomSheet(vc, isSmallDetent: isSmallDetent)
        }
    }

    /// UISheetPresentationController 설정 후 present
    private func configureAndPresentBottomSheet(_ vc: UIViewController, isSmallDetent: Bool) {
        vc.modalPresentationStyle = .pageSheet
        if let sheet = vc.sheetPresentationController {
            let customDetentId = UISheetPresentationController.Detent.Identifier("customDetentId")
            let customDetent = UISheetPresentationController.Detent.custom(identifier: customDetentId) { _ in
                return isSmallDetent ? 312 : 516
            }
            sheet.detents = [customDetent]
            sheet.preferredCornerRadius = 12
            sheet.selectedDetentIdentifier = customDetentId
        }
        present(vc, animated: true)
    }

}
    
extension ViewerViewController: MainVideoCellDelegate {
    func mainVideoCellDidTapListIcon(_ cell: MainVideoCell) {
        let myListVC = ContentSelectionViewController()
        
        presentBottomSheet(myListVC, isSmallDetent: false)
    }
}

extension ViewerViewController: IAPBottomSheetViewControllerDelegate {
    func didTappedMore() {
        guard let vc = AppContext.container.resolve(InAppPurchaseViewController.self,
                                                    argument: "0" ) else { return }
        navigationController?.pushHidesBottomBarViewController(vc, animated: true)
    }
}

extension ViewerViewController: TastedVideoCellDelegate {
    func tastedVideoCellDidTapMoveToMainViewer(_ cell: TastedVideoCell) {
        guard let vc = AppContext.container.resolve(ViewerViewController.self,
                                                             argument: ViewerType.mainViewer) else { return }
        navigationController?.pushHidesBottomBarViewController(vc, animated: true)
    }
}
