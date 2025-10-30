import UIKit
import SnapKit
import Combine
import AVFoundation
import AVKit

// 진입 라우트: main(PlayInput 포함) / tasted
enum ViewerRoute {
    case main(PlayInput)
    case tasted
}

extension ViewerRoute {
    var viewerType: ViewerType {
        switch self {
        case .main:   return .mainViewer
        case .tasted: return .tastedViewer
        }
    }
}

final class ViewerViewController: UIViewController {
    
    
    deinit {
        printX("메모리 해제")
        for case let cell as VideoPlayableCell in collectionView.visibleCells {
            cell.cleanUp()
        }
        // 플레이어 에셋 전부 해제
        engine.shrink(keeping: [])
    }
    
    //    private let currentViewerType: ViewerType
    
    //    private let input: PlayInput?
    private let engine = PlaybackEngine()
    
    private let route: ViewerRoute
    private var viewModel: ViewerViewModel
    // 기존 코드 호환용: 필요할 때 타입만 참조
    private var currentViewerType: ViewerType { route.viewerType }
    
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
    private var promotionItems: [VideoItem] { (0..<5).map  { _ in VideoItem() } }
    
    init(route: ViewerRoute, viewModel: ViewerViewModel) {
        self.route = route
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    // 스크롤 이벤트에서 센터 변경 시
    func notifyCenterChanged(_ idx: Int) {
        viewModel.move(to: idx)
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
        bind(viewModel)
        bindNotifications()
        collectionView.makeSecure()
        
        switch route {
        case .main(let input):
            viewModel.start(route: .main(input))
        case .tasted:
            viewModel.start(route: .tasted)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // 스크롤이 멈춘 것처럼 처리해서 초기 셀 재생
        // 아이템 없으면 재생 루틴 호출 안 함
        let count = dataSource.snapshot().itemIdentifiers.count
        if count > 0 {
            scrollViewDidEndDecelerating(collectionView)
        }
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
    
    
    private func makeMeta(for index: Int) -> MainVideoCell.EpisodeMetaViewData {
        let items = viewModel.items
        let safeIdx = max(0, min(index, items.count - 1))
        let it = items[safeIdx]
        let detail = viewModel.detail
        let displayIndex: Int = Int(it.episodeAlias) ?? (safeIdx + 1)
        let totalByAlias: Int = {
            let nums = items.compactMap { Int($0.episodeAlias) }
            if nums.max() == 0 {
                return items.count
            } else {
                return nums.max() ?? items.count
            }
        }()
        
        return MainVideoCell.EpisodeMetaViewData(
            contentsId:detail?.id ?? "",
            episodeId: it.episodeId,
            title: detail?.title ?? "",
            index: displayIndex,
            totalCount: totalByAlias,
            isLiked: detail?.isLiked ?? false,
            likeCount: detail?.likesCount ?? 0,
            isWished: detail?.isFavorite ?? false,
            externalSubtitleURLs: nil
        )
    }
    
    private func makeTastedMeta(for index: Int) -> TastedVideoCell.TastedVideoCellViewData {
        let items = viewModel.items
        let safeIdx = max(0, min(index, items.count - 1))
        let it = items[safeIdx]
        let detail = viewModel.tastedDetail(at: safeIdx)
        // [Tag] -> 정렬(주키: orderNumber, 보조키: name, tagId) -> [String]
        let keywords: [String]? = {
            guard let tags = detail?.keywordTags, !tags.isEmpty else { return nil }
            // 보조키까지 넣으면 정렬이 항상 안정적
            let sorted = tags.sorted { (l, r) in
                if l.orderNumber != r.orderNumber { return l.orderNumber < r.orderNumber }
                if l.name        != r.name        { return l.name        < r.name        }
                return l.tagId   < r.tagId
            }
            // 중복 name 제거
            var seen = Set<String>()
            var names: [String] = []
            for t in sorted where seen.insert(t.name).inserted {
                names.append(t.name)
            }
            return names
        }()
        
        return TastedVideoCell.TastedVideoCellViewData(
            contentsId: detail?.id ?? "",
            episodeId: it.episodeId,
            
            titleImagePath: detail?.titleImagePath ?? "",
            signatureText: detail?.signatureText,
            contractType: detail?.contractType,
            keywordTags: keywords,
            
            isLiked: detail?.isLiked ?? false,
            likeCount: detail?.likesCount ?? 0,
            isWished: detail?.isFavorite ?? false,
            externalSubtitleURLs: nil
        )
    }
    
    
    
    func setupUI() {
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        view.backgroundColor = UIColor(.backgroundDefault)
        setupCollectionView()
        configureDataSource()
        applySnapshot()
    }
    
    private func bind(_ vm: ViewerViewModel) {
        
        vm.didPrepareDetail
            .receive(on: RunLoop.main)
            .sink { [weak self] idx in
                guard let self = self else { return }
                let ip = IndexPath(item: idx, section: 0)
                guard let cell = self.collectionView.cellForItem(at: ip) as? TastedVideoCell else { return }
                let meta = self.makeTastedMeta(for: idx)
                cell.applyUIOnly(meta)
            }
            .store(in: &subscriptions)
        
        // ⚠️ shrink() 비활성화 - DRM AVContentKeySession 크래시 방지
        // keepEpisodeIds 기반 asset 해제 시 AVContentKeySession이 해제되어
        // "AVContentKeyRequest can no longer process key responses" 크래시 발생
        // 한번 로드된 asset은 메모리에 유지하여 안정성 확보
        // vm.keepEpisodeIds
        //     .receive(on: RunLoop.main)
        //     .sink { [weak self] keep in
        //         self?.engine.shrink(keeping: keep)
        //     }
        //     .store(in: &subscriptions)
        
        vm.$detail
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.applyMetaToVisibleCells()
            }
            .store(in: &subscriptions)
        
        // 아이템 개수 바인딩 → 스냅샷 갱신
        vm.$items
            .receive(on: RunLoop.main)
            .sink { [weak self] items in
                guard let self else { return }
                var snapshot = NSDiffableDataSourceSnapshot<Section, VideoItem>()
                switch self.currentViewerType {
                case .mainViewer:
                    snapshot.appendSections([.main])
                    snapshot.appendItems((0..<items.count).map { _ in VideoItem() }, toSection: .main)
                case .tastedViewer:
                    snapshot.appendSections([.tasted])
                    snapshot.appendItems((0..<items.count).map { _ in VideoItem() }, toSection: .tasted)
                case .promotionViewer:
                    snapshot.appendSections([.promotion])
                    snapshot.appendItems(self.promotionItems, toSection: .promotion)
                }
                self.dataSource.apply(snapshot, animatingDifferences: false)
                if !items.isEmpty { self.scrollViewDidEndDecelerating(self.collectionView) }
            }
            .store(in: &subscriptions)
        
        // 특정 index의 플레이백이 준비되면 보이는 셀에 적용
        vm.didPreparePlayback
            .receive(on: RunLoop.main)
            .sink { [weak self] idx in
                guard let self else { return }
                let indexPath = IndexPath(item: idx, section: 0)
                guard let pb = self.viewModel.playback(at: idx) else { return }
                
                let desc = PlaybackDescriptor(
                    episodeId: pb.episodeId,
                    assetKey: pb.contentId,                  // videoId를 에셋키로
                    videoId: pb.videoId,
                    manifestURL: pb.manifestURL,
                    drmToken: pb.drmToken,
                    cfCookieHeader: pb.cfCookieHeader
                )
                self.engine.prepare(desc)
                guard let item = self.engine.item(for: desc.episodeId) else { return }
                
                if let cell = self.collectionView.cellForItem(at: indexPath) as? MainVideoCell {
                    let meta = self.makeMeta(for: idx)
                    cell.apply(playerItem: item, meta: meta)
                } else if let cell = self.collectionView.cellForItem(at: indexPath) as? TastedVideoCell {
                    let meta = self.makeTastedMeta(for: idx)
                    cell.apply(playerItem: item, meta: meta)
                }
                if let cell = self.collectionView.cellForItem(at: IndexPath(item: idx, section: 0)) as? VideoPlayableCell {
                    // 화면 중앙이면 재생 보정
                    let center = self.view.convert(self.collectionView.center, to: self.collectionView)
                    if let centerIP = self.collectionView.indexPathForItem(at: center),
                       centerIP.item == idx { cell.playPlayer() }
                }
                
            }
            .store(in: &subscriptions)
        
        viewModel.errors
            .receive(on: RunLoop.main)
            .sink { [weak self] err in
                guard let self else { return }
                // 1) 메시지 결정: 뷰모델에서 보낸 커스텀 UI 에러가 있으면 그걸, 아니면 기본 설명
                let msg: String
                if let e = err as? ViewerUIError {
                    msg = e.message
                    // 2A) 공용 토스트 뷰로 (아이콘 없이)
                    let toast = LZSnackToastView(text: msg, showsIcon: false)
                    LZSnackToastHelper.showOnce(on: nil, toast: toast, duration: 2.0, bottomMargin: 150) { [weak self] in
                      
                        if let nav = self?.navigationController, nav.viewControllers.count > 1 {
                            nav.popViewController(animated: true)
                        } else {
                            self?.dismiss(animated: true)
                        }
                    }
                } else {
                    let popup = LZSnackAlertPopupView(
                        width: 320,
                        height: 222,
                        title: " 오류",
                        message: err.localizedDescription,
                        buttonTitle: "닫기",
                        handler: {  },
                        showsCloseButton: true,
                        closeHandler: {  }
                    )
                    popup.show()
                }
            }
            .store(in: &subscriptions)
    }
    
    func bindNotifications() {
        NotificationCenter.default.publisher(for: .drmLicenseFailed)
            .receive(on: RunLoop.main)
            .sink { [weak self] noti in
                guard let self = self else { return }
                let contentId = noti.userInfo?["contentId"] as? String ?? "Unknown"
                let err = (noti.userInfo?["error"] as? Error)?.localizedDescription ?? "알 수 없는 오류"
                
                // 1) 재생중지/정리 (해당 셀 찾아 정리)
                for case let cell as VideoPlayableCell in self.collectionView.visibleCells {
                    cell.pausePlayer()
                }
                
                // 2) 사용자 알림
                let ac = UIAlertController(
                    title: "재생 오류",
                    message: "DRM 라이선스 발급 실패\n콘텐츠: \(contentId)\n사유: \(err)",
                    preferredStyle: .alert
                )
                ac.addAction(UIAlertAction(title: "확인", style: .default))
                self.present(ac, animated: true)
                
                // 3) 필요하면 다음 아이템으로 스크롤
            }.store(in: &subscriptions)
        
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
            .compactMap { $0.object as? Int }     // ← 코인(Int)만 받기
            .receive(on: RunLoop.main)
            .sink { [weak self] coin in
                guard let self = self,
                      let vc = AppContext.container.resolve(
                        IAPBottomSheetViewController.self,
                        argument: "\(coin)"
                      )
                else { return }
                vc.delegate = self
                self.presentBottomSheet(vc, isSmallDetent: false)
            }
            .store(in: &subscriptions)
        
//        NotificationCenter.default.publisher(for: .LZSPurchaseEpisodeReceiveNotification)
//            .compactMap { $0.object as? Int }
//            .receive(on: RunLoop.main)
//            .sink { [weak self] coin in
//                
//                guard let self = self, let vc = AppContext.container.resolve(IAPBottomSheetViewController.self,
//                                                                             argument: "\(coin)" ) else { return }
//                vc.delegate = self
//                presentBottomSheet(vc,isSmallDetent: false)
//            }.store(in: &subscriptions)
//        
//        NotificationCenter.default.publisher(for: .LZSEarlyAccessReceiveNotification)
//            .receive(on: RunLoop.main)
//            .sink { [weak self] _ in
//                
//            }.store(in: &subscriptions)
        
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
        case .promotionViewer:
            snapshot.appendSections([.promotion])
            snapshot.appendItems(promotionItems, toSection: .promotion)
            
        case .tastedViewer:
            snapshot.appendSections([ .tasted ])
        }
        
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    private func bindRefreshLoading() {
        viewModel.$isRefreshingTasted
            .receive(on: DispatchQueue.main)
            .sink { [weak self] refreshing in
                guard let self else { return }
                if refreshing {
                } else {
                    // 새 목록 로드 후 첫 셀로 스냅
                    let first = IndexPath(item: 0, section: 0)
                    if self.collectionView.numberOfItems(inSection: 0) > 0 {
                        self.collectionView.scrollToItem(at: first, at: .centeredVertically, animated: false)
                    }
                }
            }
            .store(in: &subscriptions)
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
        
        guard dataSource.snapshot().itemIdentifiers.count > 0 else { return }
        
        // 1) 화면의 모든 VideoPlayableCell 일시정지
        for case let cell as VideoPlayableCell in collectionView.visibleCells {
            cell.pausePlayer()
        }
        // 2) 중앙 셀 찾아서 재생
        let center = view.convert(collectionView.center, to: collectionView)
        if let indexPath = collectionView.indexPathForItem(at: center),
           let cell = collectionView.cellForItem(at: indexPath) as? VideoPlayableCell {
            cell.playPlayer()
            viewModel.move(to: indexPath.item)
        }
    }
    
    // willDisplay에서 준비된 item을 셀에 전달
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        //        guard let cell = cell as? MainVideoCell else { return }
        guard viewModel.items.indices.contains(indexPath.item) else { return }
        switch currentViewerType {
        case .mainViewer:
            guard let cell = cell as? MainVideoCell else { return }
            let meta = makeMeta(for: indexPath.item)
            if let pb = viewModel.playback(at: indexPath.item) {
                let desc = PlaybackDescriptor(
                    episodeId: pb.episodeId,
                    assetKey: pb.contentId,
                    videoId: pb.videoId,
                    manifestURL: pb.manifestURL,
                    drmToken: pb.drmToken,
                    cfCookieHeader: pb.cfCookieHeader
                )
                engine.prepare(desc)
                if let item = engine.item(for: desc.episodeId) {
                    for case let visible as MainVideoCell in collectionView.visibleCells where visible.playerItem === item {
                        visible.cleanUp()
                    }
                    DispatchQueue.main.async {
                        cell.apply(playerItem: item, meta: meta)
                    }
                }
            } else {
                // 아직 준비 전이면 메타만
                cell.applyUIOnly(meta)
            }
            
        case .tastedViewer:
            guard let cell = cell as? TastedVideoCell else { return }
            let meta = makeTastedMeta(for: indexPath.item)
            if let pb = viewModel.playback(at: indexPath.item) {
                let desc = PlaybackDescriptor(
                    episodeId: pb.episodeId,
                    assetKey: pb.contentId,
                    videoId: pb.videoId,
                    manifestURL: pb.manifestURL,
                    drmToken: pb.drmToken,
                    cfCookieHeader: pb.cfCookieHeader
                )
                engine.prepare(desc)
                if let item = engine.item(for: desc.episodeId) {
                    for case let visible as TastedVideoCell in collectionView.visibleCells where visible.playerItem === item {
                        visible.cleanUp()
                    }
                    DispatchQueue.main.async {
                        cell.apply(playerItem: item, meta: meta)
                    }
                }
            } else {
                // 플레이어 준비 전 — 스켈레톤/프로모션/타이틀 등만 먼저
                cell.applyUIOnly(meta)
            }
            
        case .promotionViewer:
            break
        }
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
    
    func videoCellDidReach3s(_ cell: VideoPlayableCell, contentsId: String, episodeId: String) {
        Task { @MainActor in
            await viewModel.trackViewIfNeeded(contentsId: contentsId, episodeId: episodeId, tastedMode: viewModel.viewerType == .tastedViewer)
        }
        
    }
    
    
    private func applyMetaToVisibleCells() {
        for case let cell as MainVideoCell in collectionView.visibleCells {
            if let indexPath = collectionView.indexPath(for: cell) {
                let meta = makeMeta(for: indexPath.item)
                cell.applyUIOnly(meta)
            }
        }
    }
    
    func videoCellDidTapLikeButton(_ cell: any VideoPlayableCell) {
        switch cell {
        case is MainVideoCell:
            guard let cell = cell as? MainVideoCell else { return }
            Task { @MainActor in
                viewModel.likeTapped()
            }
            //            cell.isLikeEpisode.toggle()
        case is TastedVideoCell:
            guard let cell = cell as? TastedVideoCell else { return }
            Task { @MainActor in
                viewModel.likeTapped()
            }
            //            cell.isLikeEpisode.toggle()
        default: break
        }
    }
    
    func videoCellDidTapWishButton(_ cell: any VideoPlayableCell) {
        switch cell {
        case is MainVideoCell:
            guard let cell = cell as? MainVideoCell else { return }
            Task { @MainActor in
                let before = viewModel.detail?.isFavorite ?? false
                await viewModel.toggleFavorite()
                let after = viewModel.detail?.isFavorite ?? before
                
                // (선택) 결과 토스트만 표시
                toastWhenListViewAddOrDelete(after)
                
            }
            //            cell.isWishedEpisode.toggle()
            //            toastWhenListViewAddOrDelete(cell.isWishedEpisode)
        case is TastedVideoCell:
            guard let cell = cell as? TastedVideoCell else { return }
            Task { @MainActor in
                let center = collectionView.indexPathForItem(at: view.convert(collectionView.center, to: collectionView))?.item ?? 0
                let before = viewModel.tastedDetail(at: center)?.isFavorite ?? false
                await viewModel.toggleFavorite()
                let after  = viewModel.tastedDetail(at: center)?.isFavorite ?? before
                toastWhenListViewAddOrDelete(after)
                
            }
            //            cell.isWishedEpisode.toggle()
            //            toastWhenListViewAddOrDelete(cell.isWishedEpisode)
        default: break
        }
    }
    
    func toastWhenListViewAddOrDelete(_ isWished: Bool) {
        // 1) 메시지와 아이콘 표시 여부를 분기
        let message = isWished ? "내 목록에서 추가 되었습니다." : "삭제가 완료되었습니다."
        let showsIcon = isWished
        
        let toastView = LZSnackToastView(text: message, showsIcon: showsIcon)
        LZSnackToastHelper.showOnce(on: nil, toast: toastView, duration: 2.0,bottomMargin: 150)
    }
    
    func videoCellDidTapShareButton(_ cell: any VideoPlayableCell) {
        switch cell {
        case is MainVideoCell:
            let vc = RecommendViewController()
            
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true)
            
        case is TastedVideoCell:
            guard let vc = AppContext.container.resolve(IAPBottomSheetViewController.self,
                                                        argument: "30" ) else { return }
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
        if viewModel.viewerType == .tastedViewer {
            Task { await viewModel.tastedPlaybackDidFinish(at: idx.item) }
        } else {
            let next = IndexPath(item: idx.item + 1, section: idx.section)
            guard next.item < dataSource.snapshot().numberOfItems else { return }
            // 스크롤 애니메이션 시작
            collectionView.scrollToItem(at: next, at: .centeredHorizontally, animated: true)
        }
        
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
        // 현재 중앙 아이템 인덱스
        let center = view.convert(collectionView.center, to: collectionView)
        let current = collectionView.indexPathForItem(at: center)?.item ?? 0
        let purchased = viewModel.purchasedEpisodeIds
        guard let detail = viewModel.detail else {
            LZSnackToastHelper.showOnce(message: "작품 정보를 불러오는 중입니다.", position: .center)
            return
        }
        let episodes = viewModel.episodes
        
        let input = ContentSelectionInput(
            contents: detail,
            episodes: episodes,
            currentIndex: current,
            purchasedEpisodeIds: purchased)
        
        let sheet = ContentSelectionViewController()
        sheet.attach(input: input)   // ✅ 핵심
        presentBottomSheet(sheet, isSmallDetent: false)
        
    }
}

extension ViewerViewController: IAPBottomSheetViewControllerDelegate {
    func didTappedMore() {
        guard let vc = AppContext.container.resolve(InAppPurchaseViewController.self,
                                                    argument: "20" ) else { return }
        navigationController?.pushHidesBottomBarViewController(vc, animated: true)
    }
}

extension ViewerViewController: TastedVideoCellDelegate {
    func tastedVideoCellDidTapMoveToMainViewer(_ cell: TastedVideoCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        
        // 1) detail이 준비되어 있으면 그 값 우선 사용
        let detail = viewModel.tastedDetail(at: indexPath.item)
        
        // 2) contentsAlias 확보 (detail.alias → tastedItems[].contentsAlias 폴백)
        let contentsAlias: String? = detail?.alias ?? (indexPath.item < viewModel.tastedItems.count ? viewModel.tastedItems[indexPath.item].contentsAlias : nil)
        
        // 3) 필수 파라미터 가드
        guard let alias = contentsAlias, !alias.isEmpty else {
            // 필요 시 토스트/알럿
            LZSnackToastHelper.showOnce(message: "시청할 수 없는 콘텐츠입니다. contentsAlias, !alias.isEmpty ", duration: 2.0, position: .bottom, allowDuplicate: false)
            return
        }
        
        // 4) episodeAlias는 detail이 준비되어 있을 때만 넣고, 없으면 nil로 전달
        //    (메인 뷰어는 내부에서 detail을 다시 받아 firstEpisodeAlias → "1" 순으로 처리)
        let epAlias = detail?.firstEpisodeAlias
        
        let playInput = PlayInput(contentsAlias: contentsAlias ?? "", episodeAlias: epAlias)
        let route = ViewerRoute.main(playInput)
        
        guard let vc = AppContext.container.resolve(ViewerViewController.self,arguments: ViewerType.mainViewer, route) else { return }
        navigationController?.pushHidesBottomBarViewController(vc, animated: true)
    }
}
