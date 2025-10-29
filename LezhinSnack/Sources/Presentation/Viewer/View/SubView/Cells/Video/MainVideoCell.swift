import UIKit
import SwiftSubtitles
import Alamofire
import SnapKit
import Combine
import AVFoundation
import AVKit
import PallyConFPSSDK

// 1) 플레이어 셀용 프로토콜 (재생·일시정지·정리 + 델리게이트 콜백)
protocol VideoPlayableCell: AnyObject {
    // 플레이어 동작
    func configure()
    func playPlayer()
    func pausePlayer()
    func cleanUp()

    // 델리게이트
    var delegate: VideoPlayableCellDelegate? { get set }
}

// 2) 델리게이트 메서드를 이쪽으로 이동
protocol VideoPlayableCellDelegate: AnyObject {
    func videoCell(_ cell: VideoPlayableCell,didTapSpeedButton button: UIButton, playbackRates: [Float])
    func videoCell(_ cell: VideoPlayableCell,didTapSubtitleButton button: UIButton, availableOptions: [AVMediaSelectionOption])
    func videoCellDidFinishPlayback(_ cell: VideoPlayableCell)
    func videoCellDidTapBack(_ cell: VideoPlayableCell)
    func videoCellDidTapLikeButton(_ cell: VideoPlayableCell)
    func videoCellDidTapWishButton(_ cell: VideoPlayableCell)
    func videoCellDidTapShareButton(_ cell: VideoPlayableCell)
    func videoCellDidReach3s(_ cell: VideoPlayableCell, contentsId: String, episodeId: String)
}

protocol MainVideoCellDelegate: AnyObject {
    func mainVideoCellDidTapListIcon(_ cell: MainVideoCell)
}

final class MainVideoCell: UICollectionViewCell, VideoPlayableCell {
    
    private let certificateURL = URL(string: "https://license-global.pallycon.com/ri/fpsKeyManager.do?siteId=UVOO")!
    private let licenseServerURL = URL(string: "https://license-global.pallycon.com/ri/licenseManager.do")!
    private let pallyconToken = "eyJrZXlfcm90YXRpb24iOmZhbHNlLCJyZXNwb25zZV9mb3JtYXQiOiJvcmlnaW5hbCIsInVzZXJfaWQiOiIxMjQxMjMxIiwiZHJtX3R5cGUiOiJGYWlyUGxheSIsInNpdGVfaWQiOiJVVk9PIiwiaGFzaCI6ImJPc2JqT0tNLzBCY0F2VTB4bnFraWliV2F1S3NHelY0bnNtWldKNWJPSTQ9IiwiY2lkIjoiMTM4OTE3MjgiLCJwb2xpY3kiOiJxUXRpenZQcEFBbGd0eDF4M082VDBYemhPcW84b1o5clJKYVBBelA2dzgwPSIsInRpbWVzdGFtcCI6IjIwMjUtMDQtMzBUMDg6NDY6MjFaIn0"
    
    private let externalSubtitleURLs: [URL] = [
      URL(string: "https://d14w94eqy435vb.cloudfront.net/rainandyou/1min_rainandyou_1080x1920_kor.vtt")!,
      URL(string: "https://d14w94eqy435vb.cloudfront.net/rainandyou/1min_rainandyou_1080x1920_jp.vtt")!,
      URL(string: "https://d14w94eqy435vb.cloudfront.net/rainandyou/1min_rainandyou_1080x1920_eng.vtt")!,
      URL(string: "https://d14w94eqy435vb.cloudfront.net/rainandyou/1min_rainandyou_1080x1920_chi.vtt")!
    ]
    
    deinit {
        printX("뷰어셀 파괴", isBoxMode: true)
    }
    
    struct EpisodeMetaViewData: Hashable {
        let contentsId: String
        let episodeId: String
        let title: String            // 상단 타이틀
        let index: Int               // 1-based
        let totalCount: Int
        let isLiked: Bool
        let likeCount: Int
        let isWished: Bool
        let externalSubtitleURLs: [URL]? // 있으면 VTT 로드
        
    }
    // MARK: Properties
//    private var fpsSDK: PallyConFPSSDK?
//    private var drmConfig: PallyConDrmConfiguration?
    
    private var didReport3Sec = false
    private var currentContentsId: String?
    private var currentEpisodeId: String?
    
    private var diagCancellables = Set<AnyCancellable>()
    
    var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private var timeObserverToken: Any?
    var playerItem: AVPlayerItem?
    private var pipController: AVPictureInPictureController?
    
    private var isUserInteractingWithSlider = false
    private var legibleOutput: AVPlayerItemLegibleOutput?
    private var availableSubtitleOptions: [AVMediaSelectionOption] = []
    private let captionOutput = AVPlayerItemLegibleOutput()
    
    private var isObservingPlaybackState = true
    private var hasShownInitControls = false
    private var areControlsVisible = false
    private var initialHideWorkItem: DispatchWorkItem?
    
    weak var delegate: VideoPlayableCellDelegate?
    
    // MARK: UI Components
    
    private let videoContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(.backgroundDefault)
        return view
    }()
    
    private let topGradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = [
            UIColor(red: 0.039, green: 0.043, blue: 0.055, alpha: 0.72).cgColor,
            UIColor(red: 0.039, green: 0.043, blue: 0.055, alpha: 0).cgColor
        ]
        layer.startPoint = CGPoint(x: 0.5, y: 0.0)
        layer.endPoint = CGPoint(x: 0.5, y: 1.0)
        layer.opacity = 0
        return layer
    }()
    
    private let bottomGradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = [
            UIColor(red: 0.039, green: 0.043, blue: 0.055, alpha: 0).cgColor,
            UIColor(red: 0.039, green: 0.043, blue: 0.055, alpha: 0.94).cgColor
        ]
        layer.startPoint = CGPoint(x: 0.5, y: 0.0)
        layer.endPoint   = CGPoint(x: 0.5, y: 1.0)
        layer.opacity    = 0
        return layer
    }()
    
    private var endPlaybackCancellable: AnyCancellable?
    
    //MARK: 하단 뷰어 컨트롤러 UI
    private let bottomControlsContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private let playPauseButton: UIButton = {
        let button = UIButton(type: .system)
        
        let playIcon = UIImage(named: "ic_play_fill")?.withRenderingMode(.alwaysOriginal)
        button.setImage(playIcon, for: .normal)
        
        return button
    }()
    
    private let pauseTimeLabel: UILabel = {
        let label = UILabel()
        label.font = .pretendardMedium(size: 13)
        label.textColor = .white
        label.textAlignment = .left
        return label
    }()
    
    private let playbackRates: [Float] = [0.5, 1.0, 1.5, 2.0]

    // 2. 속도 선택 버튼
    lazy var speedButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("1.0x", for: .normal)    // 기본 타이틀
        button.titleLabel?.font = .pretendardSemiBold(size: 14)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(speedButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private let seekSlider: LZSnackTapSlider = {
        let seekSlider = LZSnackTapSlider()

        let thumbImage = UIImage(named: "ic_slider_thumb")
        let paddedThumb = thumbImage?.withTransparentPadding(20)
        
        seekSlider.setThumbImage(thumbImage, for: .normal)
        seekSlider.setThumbImage(thumbImage, for: .highlighted)
        
        seekSlider.minimumTrackTintColor = UIColor(.brandRed)
        
        seekSlider.value = 0
        
        return seekSlider
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = .pretendardMedium(size: 13)
        label.textColor = .white
        label.textAlignment = .left
        return label
    }()
    
    
    private var playbackStateObserver: AnyCancellable?
    
    
    // 자막 선택 버튼
    private lazy var subtitleButton: UIButton = {
        let button = UIButton(type: .system)
        
        let subtitleIcon = UIImage(named: "ic_subtitles")?.withRenderingMode(.alwaysOriginal)
        button.setImage(subtitleIcon, for: .normal)
        
        button.addTarget(self, action: #selector(subtitleButtonTapped), for: .touchUpInside)
        
        return button
    }()
    
    // 현재 배속 (기본값 1.0)
    var currentPlaybackRate: Float = 1.0
    
    
    private var statusObserver: AnyCancellable?
    
    //MARK: 우측 컨테이너 뷰
    private let rightContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    
    let playButtonImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "ic_play_fill"))
        imageView.backgroundColor = .clear
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    
    private lazy var shareContainerView: UIView = {
        let view = UIView()
        view.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(shareButtonTapped(_:)))
        view.addGestureRecognizer(tap)
        return view
    }()
    
    private let shareIcon: UIImageView = {
        UIImageView(image: UIImage(named: "ic_share")?.withRenderingMode(.alwaysOriginal))
    }()
    
    private let shareLabel: UILabel = {
        let label = UILabel()
        label.font = .pretendardMedium(size: 13)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = "공유"
        return label
    }()
    
    private lazy var listContainerView: UIView = {
        let view = UIView()
        view.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(listButtonTapped(_:)))
        view.addGestureRecognizer(tap)
        return view
    }()
    
    private let listIcon: UIImageView = {
        UIImageView(image: UIImage(named: "ic_library")?.withRenderingMode(.alwaysOriginal))
    }()

    private let listLabel: UILabel = {
        let label = UILabel()
        label.font = .pretendardMedium(size: 13)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = "목록"
        return label
    }()
    
    var isWishedEpisode: Bool = false {
        didSet {
            if isWishedEpisode {
                self.wishIcon.image = UIImage(named: "ic_bookmark_fill")?.withRenderingMode(.alwaysOriginal)
            } else {
                self.wishIcon.image = UIImage(named: "ic_bookmark")?.withRenderingMode(.alwaysOriginal)
            }
        }
    }
    
    private lazy var wishiConContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        
        view.isUserInteractionEnabled = true
        let wishIconTap = UITapGestureRecognizer(target: self, action: #selector(wishButtonTapped(_:)))
        view.addGestureRecognizer(wishIconTap)
        
        return view
    }()
    
    private let wishIcon: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "ic_bookmark")?.withRenderingMode(.alwaysOriginal))
        return imageView
    }()
    
    private let wishLabel: UILabel = {
        let label = UILabel()
        label.font = .pretendardMedium(size: 13)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = "찜"
        return label
    }()
    
    
    var isLikeEpisode = false {
        didSet {
            if isLikeEpisode {
                self.likeIcon.image = UIImage(named: "ic_heart_fill")?.withRenderingMode(.alwaysOriginal)
            } else {
                self.likeIcon.image = UIImage(named: "ic_heart")?.withRenderingMode(.alwaysOriginal)
            }
        }
    }

    private lazy var likeContainerView: UIView = {
        let view = UIView()
        view.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(likeButtonTapped(_:)))
        view.addGestureRecognizer(tap)
        return view
    }()
    
    private lazy var likeIcon: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "ic_heart")?.withRenderingMode(.alwaysOriginal))
        return imageView
    }()
    
    private let likeLabel: UILabel = {
        let label = UILabel()
        label.font = .pretendardMedium(size: 13)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = "0"
        return label
    }()
    
    // ★ 작품 단위 식별/카운트
    private var workId: String?
    private var likeCount: Int = 0 {
        didSet { likeLabel.text = MainVideoCell.formatLikeCount(likeCount) }
    }
    // ★ 300~600ms 딜레이: 여기선 400ms로 고정(기획 범위 내)
    private var likeThrottleUntil: DispatchTime = .now()
    private var likeRequestInFlight = false
    
    // ★ 정수 천단위 + M/B 축약 (소수 1자리, 버림)
    private static let intFormatter: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.groupingSeparator = ","
        return f
    }()
    
    private let topContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private lazy var topBackButton: UIButton = {
        let button = UIButton(type: .custom)
        let image = UIImage(named: "ic_chevron_left_white")?
            .withRenderingMode(.alwaysOriginal)
        
        button.setImage(image, for: .normal)
        
        button.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        return button
    }()
    
    
    private let topInnerTitleContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private let topEpisodeTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .pretendardBold(size: 16)
        label.textColor = .white
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }()
    
    private let episodeCountLabel: UILabel = {
        let label = UILabel()
        label.font = .pretendardMedium(size: 13)
        label.textColor = .white
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        cleanUp()
        
    }

    func cleanUp() {
        diagCancellables.removeAll()
        
        // 1) Combine 구독 취소
        playbackStateObserver?.cancel(); playbackStateObserver = nil
        statusObserver?.cancel(); statusObserver = nil
        endPlaybackCancellable?.cancel(); endPlaybackCancellable = nil
        
        // 2) Time Observer 해제
        if let token = timeObserverToken {
            player?.removeTimeObserver(token)
            timeObserverToken = nil
        }
        
        // 3) LegibleOutput 제거 (중요: item에서 빼야 함)
        if let output = legibleOutput, let item = player?.currentItem {
            item.remove(output)
        }
        legibleOutput = nil
        availableSubtitleOptions.removeAll()
        
        // 4) PiP 정지
        pipController?.stopPictureInPicture()
        pipController = nil
        
        // 5) 레이어 분리 후 제거
        if let layer = playerLayer {
            layer.player = nil
            layer.removeFromSuperlayer()
            playerLayer = nil
        }
        
        // 6) 플레이어에서 아이템 분리(핵심)
        player?.replaceCurrentItem(with: nil)
        player?.cancelPendingPrerolls()
        player = nil
        
        // 7) 아이템 참조 끊기
        playerItem = nil
        
        // 8) UI/상태
        initialHideWorkItem?.cancel(); initialHideWorkItem = nil
        hasShownInitControls = false
        areControlsVisible = false
        
        didReport3Sec = false
        currentContentsId = nil
        currentEpisodeId = nil
        print("🌪️ MainVideoCell cleanUp 완료")
    }

//    func cleanUp() {
//        // 1) Combine 구독 취소
//        playbackStateObserver?.cancel()
//        statusObserver?.cancel()
//        endPlaybackCancellable?.cancel()
//
//        // 2) timeObserver 해제
//        if let token = timeObserverToken {
//            player?.removeTimeObserver(token)
//            timeObserverToken = nil
//        }
//
//        // 3) AVPlayer 정리
//        player?.pause()
//        player = nil
//
//        // 4) AVPlayerLayer 제거
//        playerLayer?.removeFromSuperlayer()
//        playerLayer = nil
//
//        // 5) PiP 중지
//        pipController?.stopPictureInPicture()
//        pipController = nil
//
//        // 6) DRM / 자막 관련
//        legibleOutput = nil
//        availableSubtitleOptions.removeAll()
//        initialHideWorkItem?.cancel()
//        initialHideWorkItem = nil
//
//        print("🌪️ MainVideoCell cleanUp 완료")
//    }

    static func formatLikeCount(_ n: Int) -> String {
        if n >= 1_000_000_000 {
            let v = floor((Double(n) / 1_000_000_000) * 10) / 10
            return "\(v)B"
        } else if n >= 1_000_000 {
            let v = floor((Double(n) / 1_000_000) * 10) / 10
            return "\(v)M"
        } else {
            return intFormatter.string(from: NSNumber(value: n)) ?? "\(n)"
        }
    }
    
    
    func pausePlayer() {
        player?.pause()
    }
    
    func playPlayer() {
        player?.playImmediately(atRate: currentPlaybackRate)
        showControlsOnce()
    }
    
    private func showControlsOnce() {
        guard !hasShownInitControls else { return }
        hasShownInitControls = true
        areControlsVisible = true
        showControls()
        let work = DispatchWorkItem { [weak self] in
            self?.hideControls()
            self?.initialHideWorkItem = nil
        }
        initialHideWorkItem = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: work)
    }
    
    private func setupUI() {
        
        contentView.backgroundColor = UIColor(.backgroundDefault)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(contentViewTapped(_:)))
        // 다른 UI 컨트롤(버튼, 슬라이더 등)이 터치 이벤트를 먼저 처리할 수 있도록 설정
        tapGesture.cancelsTouchesInView = false
        videoContainerView.addGestureRecognizer(tapGesture)
        
        contentView.addSubview(videoContainerView)
        videoContainerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        
        makeBottomControlsContainerView()
        makeRightContainerView()
        makeTopContainerView()
        
        videoContainerView.addSubview(subtitleLabel)
        subtitleLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().offset(-50)
            make.height.equalTo(200)
        }
        
        videoContainerView.layer.insertSublayer(topGradientLayer, at: 0)
        videoContainerView.layer.insertSublayer(bottomGradientLayer, at: 0)
        
    }
    
    private func makeTopContainerView() {
        contentView.addSubview(topContainerView)
        topContainerView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(12)
            make.height.equalTo(48)
        }
        
        topContainerView.addSubview(topBackButton)
        topBackButton.snp.makeConstraints { make in
            make.top.leading.bottom.equalToSuperview()
            make.width.equalTo(40)
        }
        
        topContainerView.addSubview(topInnerTitleContainerView)
        topInnerTitleContainerView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(4)
            make.leading.equalTo(topBackButton.snp.trailing)
        }

        topInnerTitleContainerView.addSubview(topEpisodeTitleLabel)
        topEpisodeTitleLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview()
            make.height.equalTo(22)
        }
        
        topEpisodeTitleLabel.text = ""
        
        topInnerTitleContainerView.addSubview(episodeCountLabel)
        episodeCountLabel.snp.makeConstraints { make in
            make.top.equalTo(topEpisodeTitleLabel.snp.bottom)
            make.leading.equalToSuperview()
        }
        
        episodeCountLabel.text = ""
    }
    
    
    private func makeRightContainerView() {
        //MARK: 우측 사이드 컨테이너 뷰
        contentView.addSubview(rightContainerView)
        rightContainerView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.width.equalTo(28)
            make.height.equalTo(284)
            make.bottom.equalTo(bottomControlsContainerView.snp.top).offset(-24)
        }
        
        rightContainerView.addSubview(shareContainerView)
        shareContainerView.snp.makeConstraints { make in
            make.bottom.leading.trailing.equalToSuperview()
            make.height.equalTo(50)
        }
        
        shareContainerView.addSubview(shareLabel)
        shareLabel.snp.makeConstraints { make in
            make.bottom.leading.trailing.equalToSuperview()
            make.height.equalTo(18)
        }
        
        shareContainerView.addSubview(shareIcon)
        shareIcon.snp.makeConstraints { make in
            make.bottom.equalTo(shareLabel.snp.top).offset(-4)
            make.height.equalTo(28)
            make.leading.trailing.equalToSuperview()
        }
        
        
        rightContainerView.addSubview(listContainerView)
        listContainerView.snp.makeConstraints { make in
            make.bottom.equalTo(shareContainerView.snp.top).offset(-28)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(50)
        }
        
        listContainerView.addSubview(listLabel)
        listLabel.snp.makeConstraints { make in
            make.bottom.leading.trailing.equalToSuperview()
            make.height.equalTo(18)
        }
        
        listContainerView.addSubview(listIcon)
        listIcon.snp.makeConstraints { make in
            make.bottom.equalTo(listLabel.snp.top).offset(-4)
            make.height.equalTo(28)
            make.leading.trailing.equalToSuperview()
        }
        
        rightContainerView.addSubview(wishiConContainerView)
        wishiConContainerView.snp.makeConstraints { make in
            make.bottom.equalTo(listContainerView.snp.top).offset(-28)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(50)
        }
        
        wishiConContainerView.addSubview(wishLabel)
        wishLabel.snp.makeConstraints { make in
            make.height.equalTo(18)
            make.leading.bottom.trailing.equalToSuperview()
        }
        
        wishiConContainerView.addSubview(wishIcon)
        wishIcon.snp.makeConstraints { make in
            make.bottom.equalTo(wishLabel.snp.top).offset(-4)
            make.height.equalTo(28)
            make.leading.trailing.equalToSuperview()
        }
        
        rightContainerView.addSubview(likeContainerView)
        likeContainerView.snp.makeConstraints { make in
            make.bottom.equalTo(wishiConContainerView.snp.top).offset(-28)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(50)
        }
        
        likeContainerView.addSubview(likeLabel)
        likeLabel.snp.makeConstraints { make in
            make.height.equalTo(18)
            make.leading.bottom.trailing.equalToSuperview()
        }
        
        likeContainerView.addSubview(likeIcon)
        likeIcon.snp.makeConstraints { make in
            make.bottom.equalTo(likeLabel.snp.top).offset(-4)
            make.height.equalTo(28)
            make.leading.trailing.equalToSuperview()
        }
    }
    
    private func makeBottomControlsContainerView() {
        //MARK: 하단 컨테이너 뷰
        contentView.addSubview(bottomControlsContainerView)
        bottomControlsContainerView.isUserInteractionEnabled = true
        bottomControlsContainerView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(54)
            make.bottom.equalToSuperview().offset(-32)
        }
        
        // 플레이/일시정지 버튼
        playPauseButton.addTarget(self, action: #selector(playPauseTapped), for: .touchUpInside)
        bottomControlsContainerView.addSubview(playPauseButton)
        playPauseButton.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.bottom.equalToSuperview()
            make.width.height.equalTo(32)
        }
        
        
        bottomControlsContainerView.addSubview(pauseTimeLabel)
        pauseTimeLabel.snp.makeConstraints { make in
            make.leading.equalTo(playPauseButton.snp.trailing).offset(12)
            make.centerY.equalTo(playPauseButton.snp.centerY)
        }
        
        // 탐색 슬라이더
        seekSlider.isContinuous = true
        seekSlider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
        bottomControlsContainerView.addSubview(seekSlider)
        seekSlider.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(playPauseButton.snp.top)
            make.height.equalTo(30)
        }
        
        bottomControlsContainerView.addSubview(subtitleButton)
        subtitleButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
            make.width.height.equalTo(32)
        }
        
        // 배속 조절 컨트롤
        bottomControlsContainerView.addSubview(speedButton)
        speedButton.snp.makeConstraints { make in
            make.trailing.equalTo(subtitleButton.snp.leading).offset(-12)
            make.bottom.equalToSuperview()
            make.width.height.equalTo(32)
        }
        
        bottomControlsContainerView.alpha = 0
    }
    
    private func setViewerSubViews(isPlay: Bool) {
        // 초기 3초 동안은 처리하지 않음
        guard hasShownInitControls else { return }
        let targetAlpha: CGFloat = isPlay ? 0 : 1
        UIView.animate(withDuration: 0.3) {
            [self.bottomControlsContainerView,
             self.rightContainerView,
             self.topContainerView].forEach { $0.alpha = targetAlpha }
        }
    }
    
    func setPauseTimeLabelText() {
        guard let item = player?.currentItem else { return }
        let current = item.currentTime()
        let total   = item.duration
        setAttributedTimeLabel(
            current: LZSUtil.formatTime(current),
            total:   LZSUtil.formatTime(total)
        )
    }
    
    private func showControls() {
        UIView.animate(withDuration: 0.3) {
            [self.bottomControlsContainerView,
             self.rightContainerView,
             self.topContainerView].forEach { $0.alpha = 1 }
            self.topGradientLayer.opacity = 1
            self.bottomGradientLayer.opacity = 1
        }
        areControlsVisible = true
    }

    private func hideControls() {
        UIView.animate(withDuration: 0.3) {
            [self.bottomControlsContainerView,
             self.rightContainerView,
             self.topContainerView].forEach { $0.alpha = 0 }
            self.topGradientLayer.opacity = 0
            self.bottomGradientLayer.opacity = 0
        }
        areControlsVisible = false
    }

    private func toggleControls() {
        if areControlsVisible {
            hideControls()
        } else {
            showControls()
        }
    }
    
    private func setAttributedTimeLabel(current: String, total: String) {
        let left  = "\(current) / "
        let right = total

        let attr = NSMutableAttributedString(
            string: left,
            attributes: [.foregroundColor: UIColor.white]
        )
        attr.append(.init(
            string: right,
            attributes: [.foregroundColor: UIColor(.foregroundSubtler)]
        ))
        pauseTimeLabel.attributedText = attr
    }
    
    // 터치 중(slider valueChanged): 썸네일 플레이어 업데이트 + pending seek 처리
    @objc private func sliderValueChanged(_ sender: UISlider) {
        guard let duration = player?.currentItem?.duration else { return }
        let totalSeconds = CMTimeGetSeconds(duration)
        guard totalSeconds.isFinite && totalSeconds > 0 else { return }
        
        // 0...1 사이 정규화된 값 → 실제 시간 계산
        let targetSeconds = Double(sender.value) * totalSeconds
        let targetTime    = CMTime(seconds: targetSeconds, preferredTimescale: 600)
        
        // 즉시 시킹
        player?.pause()  // 시킹 전 일시정지
        player?.seek(to: targetTime, toleranceBefore: .zero, toleranceAfter: .zero) { [weak self] _ in
            guard let self = self else { return }
            // 시킹 후 레이블 갱신
            let currentText = LZSUtil.formatTime(targetTime)
            let totalText   = LZSUtil.formatTime(duration)
            self.setAttributedTimeLabel(current: currentText, total: totalText)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer?.frame = contentView.bounds
        topGradientLayer.frame = CGRect(x: 0,
                                        y: 0,
                                        width: contentView.bounds.width,
                                        height: 128)
        
        bottomGradientLayer.frame = CGRect( x: 0,
                                            y: contentView.bounds.height - 240,
                                            width: contentView.bounds.width,
                                            height: 240)
    }
    
    @objc private func contentViewTapped(_ sender: UITapGestureRecognizer) {
        // 초기 자동 숨김 예약이 남아 있으면 취소
        if let work = initialHideWorkItem {
            work.cancel()
            initialHideWorkItem = nil
        }
        // 영상 재생 상태와 무관하게 UI만 토글
        toggleControls()
    }
    
    @objc private func playPauseTapped() {
        guard let player = player else { return }
        if player.timeControlStatus == .paused {
            player.playImmediately(atRate: currentPlaybackRate)
        } else {
            player.pause()
            setPauseTimeLabelText()
        }
    }
    
    @objc private func backButtonTapped() {
        delegate?.videoCellDidTapBack(self)
    }
    
    @objc private func speedButtonTapped(_ sender: UIButton) {
        delegate?.videoCell(self,
                            didTapSpeedButton: sender,
                            playbackRates: playbackRates)
    }
    
    @objc private func subtitleButtonTapped(_ sender: UIButton) {
        guard let playerItem = playerItem,
              let asset = playerItem.asset as? AVURLAsset,
              let legibleGroup = asset.mediaSelectionGroup(forMediaCharacteristic: .legible)
        else { return }
        delegate?.videoCell(self, didTapSubtitleButton: sender,
                            availableOptions: availableSubtitleOptions)
    }
    
    @objc private func playbackDidFinish(_ notification: Notification) {
        delegate?.videoCellDidFinishPlayback(self)
    }
    
    @objc private func likeButtonTapped(_ sender: UIButton) {
        // 스로틀: 너무 빠른 중복 탭 차단
        guard DispatchTime.now() >= likeThrottleUntil, !likeRequestInFlight else { return }
        likeThrottleUntil = .now() + .milliseconds(400)

        
        // 시각적 피드백(가벼운 터치감)
        likeIcon.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        UIView.animate(withDuration: 0.15, animations: {
            self.likeIcon.transform = .identity
        })
        
        // 기존 델리게이트 유지 호출(하위호환)
        delegate?.videoCellDidTapLikeButton(self)
    }
    
    @objc private func wishButtonTapped(_ sender: UIButton) {
        delegate?.videoCellDidTapWishButton(self)
    }
    
    @objc private func shareButtonTapped(_ sender: UIButton) {
        delegate?.videoCellDidTapShareButton(self)
    }
    
    @objc private func listButtonTapped(_ sender: UIButton) {
        (delegate as? MainVideoCellDelegate)?.mainVideoCellDidTapListIcon(self)
    }
    
    private var subtitleCues: [Subtitles.Cue] = []
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = .pretendardMedium(size: 14)
        label.textColor = .white
        label.backgroundColor = .clear
        label.layer.cornerRadius = 4
        label.layer.masksToBounds = true
        return label
    }()
    
}

extension MainVideoCell: PallyConFPSLicenseDelegate {
    
    func configure() {
    }
//        // HLS 스트리밍 URL (자막 메타데이터 포함)
////        guard let url = URL(string: "http://sample.vodobox.com/planete_interdite/planete_interdite_alternate.m3u8") else { return }
//        // 애플 URL
////        guard let url = URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_4x3/bipbop_4x3_variant.m3u8") else { return }
//        
//        // 애플 URL2
////        guard let url = URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_16x9/bipbop_16x9_variant.m3u8") else { return }
//        
//        // 레진 스낵 DRM O
////        guard let url = URL(string: "https://d3fg9k53r6vr6z.cloudfront.net/6f043303-bc12-4c24-b565-621eecde1282/CMAF1/1min_rainandyou_1080x1920_3M_192kbps.m3u8") else { return }
//        
//        // 레진 스낵 DRM X
////        guard let url = URL(string: "https://d3fg9k53r6vr6z.cloudfront.net/1c5b96f0-c26f-4a90-84d4-6c8ce1b53714/CMAF1/1min_rainandyou_1080x1920_3M_192kbps.m3u8") else { return }
//        
//        // 레진 스낵 signedUrl
////        guard let url = URL(string: "https://d3fg9k53r6vr6z.cloudfront.net/cmaf/VIDEO/a5316ec9-c9f3-44cc-aecc-196ae9dade0a/CMAF1/1min_rainandyou_1080x1920_5M_192kbps.m3u8?Policy=eyJTdGF0ZW1lbnQiOiBbeyJSZXNvdXJjZSI6Imh0dHBzOi8vZDNmZzlrNTNyNnZyNnouY2xvdWRmcm9udC5uZXQvY21hZi9WSURFTy9hNTMxNmVjOS1jOWYzLTQ0Y2MtYWVjYy0xOTZhZTlkYWRlMGEvQ01BRjEvKiIsIkNvbmRpdGlvbiI6eyJEYXRlTGVzc1RoYW4iOnsiQVdTOkVwb2NoVGltZSI6MTc0NTk5OTcwMn19fV19&Signature=RynDLrtBH1nkQmbbdCr8cgcYqzaZPhyrqtnt0IoXw9F9Fgh2l7dY9DyLrNW4HQoZcnvTTaGmYwdHFpsWSfEA7yL4-2ZhP7LeIt-gJRwrLF-kklRbyaCwN9zmyzqY5X31HF2wpqUb5xxGfrAbowcRLFY2HzNzLO6aEnyJRb4ltrof4PaUwlplGMaC4ZlFMPybIbEC61WdRGt~NTUymEbjg6hr234q9eiUxEUOR--p-L2oCz36zwzRwSnpIYVCYQC3AUffMs8lXbKQ1Sd--YuV8xA0h4HDATPRYsJrBRFJA~-c5EYUh-c3ybleYQih-qZLF6cCObY1klE-TE5~bHbIeg__&Key-Pair-Id=K2QQMVLCVN7V12") else { return }
//        
//        // 레진 스낵 signedUrl, DRM O
////        guard let url = URL(string: "https://d3fg9k53r6vr6z.cloudfront.net/cmaf/DRM_VIDEO/6aa77ecc-a02c-4fd5-af03-70e2fae39b4d/CMAF1/1min_rainandyou_1080x1920_3M_192kbps.m3u8?Policy=eyJTdGF0ZW1lbnQiOiBbeyJSZXNvdXJjZSI6Imh0dHBzOi8vZDNmZzlrNTNyNnZyNnouY2xvdWRmcm9udC5uZXQvY21hZi9EUk1fVklERU8vNmFhNzdlY2MtYTAyYy00ZmQ1LWFmMDMtNzBlMmZhZTM5YjRkL0NNQUYxLyoiLCJDb25kaXRpb24iOnsiRGF0ZUxlc3NUaGFuIjp7IkFXUzpFcG9jaFRpbWUiOjE3NTM1OTYxMzh9fX1dfQ__&Signature=J0gRp3ltTpxadipfWZCPMVig3C7pGjFyEEEzwKfl4FE5WVbqfhrN5tgbz3euWLCCIEE0FpgpBnaO2PDysFGWQRsk1ZCUwM1ePoKcXr9E4wCjixLYIFsLCv~bTfZrQItkZGsbDEueQgrhGeQYa-qcZFgAJGELziLs0hfGVJh66rzXan4x5T~XgEVcaXut2kTgSgRhR1bYToqnXG5z2QzzDiIN4637Kvz1HT26THEgw8o8mTDKG5vW~l2XD7v2TBgF5O8V7Z2ero5NTbk3nGoHe2Ej~VOEvsl9PgkfWkWBOpEKgkFNaIEjcIIFGrXjx6d63A31uYRJ~NDTPbauj3iYIw__&Key-Pair-Id=K2QQMVLCVN7V12") else { return }
//        
//        
//        // 목업 로컬 더미 비디오
//        guard let url = Bundle.main.url(forResource: "dummy_video", withExtension: "mp4") else { return }
//        
////        let asset = AVURLAsset(url: url)
//        
//        let certificateUrl = "https://license-global.pallycon.com/ri/fpsKeyManager.do?siteId=UVOO"
//        let contentId      = "13891728"
//        let pallyconToken  = "eyJrZXlfcm90YXRpb24iOmZhbHNlLCJyZXNwb25zZV9mb3JtYXQiOiJvcmlnaW5hbCIsInVzZXJfaWQiOiIxMjMxMjQiLCJkcm1fdHlwZSI6IkZhaXJQbGF5Iiwic2l0ZV9pZCI6IlVWT08iLCJoYXNoIjoiRnFQOXZydDdSYmxERHRIdkUwb3RkeXRpVzVDa05sYVZ0NHhSWlo3eTQ2dz0iLCJjaWQiOiIxMzg5MTcyOCIsInBvbGljeSI6InFRdGl6dlBwQUFsZ3R4MXgzTzZUMFh6aE9xbzhvWjlyUkphUEF6UDZ3ODA9IiwidGltZXN0YW1wIjoiMjAyNS0wNS0wOFQwNjo1Nzo1OFoifQ=="
//        
//        FairPlayStreamManager.shared.prepareDRM(
//            for: contentId,
//            url: url,
//            token: pallyconToken
//        )
//
//        // 2) 재사용 가능한 AVPlayerItem 가져오기
//        playerItem = FairPlayStreamManager.shared.playerItem(
//            for: contentId
//        )
//        
////        let asset = AVURLAsset(url: url)
////        playerItem = AVPlayerItem(asset: asset)
//        
//        player = AVPlayer(playerItem: playerItem)
//        
//        loadExternalSubtitles(urls: externalSubtitleURLs)
//        
////        playerItem = AVPlayerItem(asset: asset)
////        player = AVPlayer(playerItem: playerItem)
//        
//        // AVPlayerLayer 생성 및 셀의 contentView에 추가
//        playerLayer = AVPlayerLayer(player: player)
//        guard let playerLayer = playerLayer else { return }
//        playerLayer.frame = contentView.bounds
//        playerLayer.videoGravity = .resizeAspectFill
//        videoContainerView.layer.insertSublayer(playerLayer, at: 0)
////        contentView.layer.insertSublayer(playerLayer, at: 0)
//        
//        // 자막 옵션 비동기 로드 및 선택 (UI에서 선택 가능하도록 옵션 저장)
////        let key = "availableMediaCharacteristicsWithMediaSelectionOptions"
////        asset.loadValuesAsynchronously(forKeys: [key]) { [weak self] in
////            var error: NSError?
////            let status = asset.statusOfValue(forKey: key, error: &error)
////            
////            DispatchQueue.main.async {
////                if status == .loaded {
////                    if let legibleGroup = asset.mediaSelectionGroup(forMediaCharacteristic: .legible),
////                       !legibleGroup.options.isEmpty {
////                        self?.availableSubtitleOptions = legibleGroup.options
////                        // 기본 자막으로 첫 번째 옵션 선택 (원하는 경우 변경 가능)
////                        self?.playerItem?.select(self?.availableSubtitleOptions.first, in: legibleGroup)
////                        print("자막 트랙 선택됨: \(self?.availableSubtitleOptions.first?.displayName ?? "None"), locale: \(self?.availableSubtitleOptions.first?.locale?.identifier ?? "none")")
////                    } else {
////                        print("자막 트랙이 없습니다.")
////                    }
////                } else {
////                    print("자막 정보를 불러오지 못했습니다. 오류: \(error?.localizedDescription ?? "Unknown error")")
////                }
////            }
////        }
//        
//        // 자막(legible) 출력용 AVPlayerItemLegibleOutput 설정
//        let output = AVPlayerItemLegibleOutput()
//        output.setDelegate(self, queue: DispatchQueue.main)
//        player?.currentItem?.add(output)
//        legibleOutput = output
//        
//        
//        configurePlayerObservers()
//        
////        videoContainerView.makeSecure()
//    }
    
    private func updateSubtitle(at time: CMTime) {
        let currentTime = time.seconds
        
        // 현재 시간에 해당하는 자막 찾기
        for cue in subtitleCues {
            if currentTime >= cue.startTimeInSeconds && currentTime <= cue.endTimeInSeconds {
                subtitleLabel.text = cue.text
                subtitleLabel.isHidden = false
                return
            }
        }
        
        // 표시할 자막이 없으면 숨김
        subtitleLabel.isHidden = true
    }
    
    func loadExternalSubtitles(urls: [URL]) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            var allCues: [Subtitles.Cue] = []
            
            for url in urls {
                do {
                    let vttString = try String(contentsOf: url, encoding: .utf8)
                    let subtitles = try Subtitles.Coder.VTT().decode(vttString)
                    allCues.append(contentsOf: subtitles.cues)
                } catch {
                    print("자막 파싱 실패:", error)
                }
            }
            
            // 시작 시간 기준으로 정렬
            allCues.sort { $0.startTime < $1.startTime }
            
            DispatchQueue.main.async {
                self.subtitleCues = allCues
            }
        }
    }

    func configurePlayerObservers() {
        guard let player = player,
              let item = player.currentItem else { return }
        
        endPlaybackCancellable = NotificationCenter.default
            .publisher(for: .AVPlayerItemDidPlayToEndTime, object: item)
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.delegate?.videoCellDidFinishPlayback(self)
            }

        
        playbackStateObserver = player
            .publisher(for: \.timeControlStatus)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                guard let self = self,
                      self.isObservingPlaybackState else { return }
//                self.setViewerSubViews(isPlay: status == .playing)
            }
        playerItem?.observe(\.status, options: [.new, .initial]) { item, _ in
            if item.status == .failed {
                let nsErr = item.error as NSError?
                print("AVPlayerItem.status.failed:", nsErr ?? "nil",
                      nsErr?.domain ?? "", nsErr?.code ?? 0,
                      nsErr?.userInfo[NSUnderlyingErrorKey] as Any)
                if let log = item.errorLog() {
                    for e in log.events {
                        print("AVErrorLog:", e.errorStatusCode, e.errorDomain, e.serverAddress ?? "", e.uri ?? "")
                    }
                }
            }
        }
        // ✅ 추가: 재생 실패 노티 (끝까지 못 간 경우)
        NotificationCenter.default.publisher(
            for: .AVPlayerItemFailedToPlayToEndTime,
            object: item
        )
        .sink { note in
            if let err = note.userInfo?[AVPlayerItemFailedToPlayToEndTimeErrorKey] as? NSError {
                printX("🔔 FailedToPlayToEnd:\n" + LZSUtil.dumpNSErrorChain(err))
            } else {
                printX("🔔 FailedToPlayToEnd: error 없음")
            }
        }
        .store(in: &diagCancellables)
        
        
        statusObserver = item.publisher(for: \.status)   // KeyValueObservingPublisher 사용  [oai_citation:0‡Apple Developer](https://developer.apple.com/documentation/combine/performing-key-value-observing-with-combine?utm_source=chatgpt.com)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                guard let self = self else { return }
                switch status {
                case .readyToPlay:
                    // 재생 준비 완료
                    print("▶️ AVPlayerItem is ready to play.")
                case .failed:
                    // 실패 시 NSError 정보 로깅
                    if let error = item.error as NSError? {
                        
                        printX("▶️ 재생 실패 감지:\n" + LZSUtil.dumpNSErrorChain(error))
                        if let coreMediaError = CoreMediaError(error){
                            //It's core media error
                            //You can handle it here
                        }
                        
                        // 2) errorLog / accessLog
                        if let log = item.errorLog() {
                            for e in log.events {
                                printX("🧾 errorLog:", "\(e.errorDomain ?? "?")", e.errorStatusCode, e.errorComment ?? "")
                            }
                        } else {
                            printX("🧾 errorLog: none")
                        }
                        if let al = item.accessLog() {
                            for e in al.events {
                                let reqs = e.numberOfMediaRequests
                                let observed = e.observedBitrate
                                let indicated = e.indicatedBitrate
                                let uri = e.uri ?? "?"
                                let bytes = e.numberOfBytesTransferred
                                let xfer = e.transferDuration
                                let stalls = e.numberOfStalls
                                printX("📈 accessLog: requests=\(reqs) observed=\(observed) indicated=\(indicated) bytes=\(bytes) xfer=\(xfer)s stalls=\(stalls) uri=\(uri)")
                            }
                        } else {
                            printX("📈 accessLog: none")
                        }
                    } else {
                        printX("▶️ 재생 실패: 상세 오류 정보 없음")
                    }
                    
                    
//                        print("""
//                        ▶️ 재생 실패 감지:
//                          • 도메인: \(error.domain)
//                          • 코드: \(error.code)
//                          • 설명: \(error.localizedDescription)
//                        """)
//                    } else {
//                        print("▶️ 재생 실패: 상세 오류 정보 없음")
//                    }
                default:
                    break
                }
            }
        
        timeObserverToken = player.addPeriodicTimeObserver(
            forInterval: CMTime(seconds: 0.1, preferredTimescale: 600),
            queue: .main
        ) { [weak self] time in
            guard let self = self,
                  let duration = player.currentItem?.duration,
                  !self.isUserInteractingWithSlider else { return }
            
            let currentSeconds = CMTimeGetSeconds(time)
            let totalSeconds   = CMTimeGetSeconds(duration)
            guard totalSeconds.isFinite && totalSeconds > 0 else { return }
            
            self.seekSlider.value = Float(currentSeconds / totalSeconds)
            self.setPauseTimeLabelText()
            
//            guard let cues = self.parsedSubtitles?.cues else { return }
//            let t = CMTimeGetSeconds(time)
            // 현재 시점에 해당하는 Cue 찾기
            self.updateSubtitle(at: time)
            
            if !didReport3Sec, let contentsId = currentContentsId, let episodeId  = currentEpisodeId {
                let currentSeconds = CMTimeGetSeconds(time)
                if currentSeconds >= 3.0 {
                    didReport3Sec = true
                    delegate?.videoCellDidReach3s(self, contentsId: contentsId, episodeId: episodeId)
                }
            }
            
            
//            if let accessLog = player.currentItem?.accessLog(),
//               let lastEvent = accessLog.events.last {
//                let indicated = lastEvent.indicatedBitrate    // 권장 전송 비트레이트 (kbps)
//                let observed  = lastEvent.observedBitrate     // 실제 측정 비트레이트 (kbps)
//                let watched   = lastEvent.durationWatched     // 해당 세그먼트 재생 시간 (초)
//                
//                print("""
//                      ▶️ 스트림 품질 지표:
//                        • Indicated Bitrate : \(indicated) kbps
//                        • Observed Bandwidth: \(observed) kbps
//                        • Duration Watched : \(watched)s
//                      """)
//            }
            
        }
        
        // 4) 슬라이더 터치 상태 변화 처리
        seekSlider.addTarget(self, action: #selector(self.sliderTouchDown), for: .touchDown)
        seekSlider.addTarget(self, action: #selector(self.sliderTouchUp),   for: [.touchUpInside, .touchUpOutside, .touchCancel])
    }
    
    func wirePlayerObservers(player: AVPlayer, item: AVPlayerItem) {
      NotificationCenter.default.addObserver(
        forName: .AVPlayerItemNewErrorLogEntry, object: item, queue: .main
      ) { _ in
        if let e = item.errorLog()?.events.last {
          print("🧾 errorLog last:", e.errorStatusCode, e.errorComment ?? "nil", e.uri ?? "nil")
        }
      }

      NotificationCenter.default.addObserver(
        forName: .AVPlayerItemFailedToPlayToEndTime, object: item, queue: .main
      ) { n in
        let err = n.userInfo?[AVPlayerItemFailedToPlayToEndTimeErrorKey] as? NSError
        print("❌ failedToPlayToEnd:", err as Any)
      }

      NotificationCenter.default.addObserver(
        forName: .AVPlayerItemPlaybackStalled, object: item, queue: .main
      ) { _ in
        print("⏸️ playback stalled")
      }

      player.addObserver(self, forKeyPath: "timeControlStatus", options: [.new, .old], context: nil)
    }

    @objc private func sliderTouchDown(_ slider: UISlider) {
        isUserInteractingWithSlider = true
    }
    @objc private func sliderTouchUp(_ slider: UISlider) {
        isUserInteractingWithSlider = false
        
        self.player?.playImmediately(atRate: self.currentPlaybackRate)
    }
    
    
    func license(result: PallyConResult) {
        print("----- 라이선스 결과 -----")
        print("콘텐츠 ID: \(result.contentId)")
        print("키 ID    : \(result.keyId ?? "nil")")
        
        // 성공 여부 확인: 실패 시 에러 메시지 출력
        guard result.isSuccess else {
            let errorMessage = result.error?.localizedDescription ?? "에러 정보 없음"
            print("에러: \(errorMessage)")
            
            if let error = result.error {
                let detailErrorMessage: String
                switch error {
                case .database(comment: let comment):
                    detailErrorMessage = "데이터베이스 에러: \(comment)"
                case .server(errorCode: let errorCode, comment: let comment):
                    detailErrorMessage = "서버 에러 (\(errorCode)): \(comment)"
                case .network(errorCode: let errorCode, comment: let comment):
                    detailErrorMessage = "네트워크 에러 (\(errorCode)): \(comment)"
                case .system(errorCode: let errorCode, comment: let comment):
                    detailErrorMessage = "시스템 에러 (\(errorCode)): \(comment)"
                case .failed(errorCode: let errorCode, comment: let comment):
                    detailErrorMessage = "실패 (\(errorCode)): \(comment)"
                case .unknown(errorCode: let errorCode, comment: let comment):
                    detailErrorMessage = "알 수 없는 에러 (\(errorCode)): \(comment)"
                case .invalid(comment: let comment):
                    detailErrorMessage = "잘못된 요청: \(comment)"
                case .download(errorCode: let errorCode, comment: let comment):
                    detailErrorMessage = "다운로드 에러 (\(errorCode)): \(comment)"
                @unknown default:
                    detailErrorMessage = "알 수 없는 에러 유형"
                }
                print(detailErrorMessage)
            }
            return
        }
    }
}

extension MainVideoCell {
    
    /// 메타만 적용 (타이틀/회차/좋아요/찜 등) — willDisplay에서 호출
    func applyUIOnly(_ meta: EpisodeMetaViewData) {
        isLikeEpisode = meta.isLiked
        isWishedEpisode = meta.isWished
        likeCount = meta.likeCount
        
        currentContentsId = meta.contentsId
        currentEpisodeId  = meta.episodeId
    }
    
    
    /// 실제 플레이어 아이템 연결 — didPreparePlayback에서만 호출
    func apply(playerItem: AVPlayerItem, meta: EpisodeMetaViewData) {
        // 동일 회차에 대한 중복 적용 방지
//        if appliedEpisodeId == meta.episodeId { return }
//        appliedEpisodeId = meta.episodeId
        
        // 기존 연결 싹 정리
        cleanUp()

        topEpisodeTitleLabel.text = meta.title
        episodeCountLabel.text = "\(meta.index)/\(meta.totalCount)"
        isLikeEpisode = meta.isLiked
        likeCount = meta.likeCount
        isWishedEpisode = meta.isWished
        
        currentContentsId = meta.contentsId
        currentEpisodeId  = meta.episodeId
        
        // 외부 VTT 미리 로드만 하고, 플레이어 연결/옵저버는 절대 하지 않음
        if let urls = meta.externalSubtitleURLs, !urls.isEmpty {
            loadExternalSubtitles(urls: urls)
        }
        
        // 2) Player/Layer 연결
        self.playerItem = playerItem
        let player = AVPlayer(playerItem: playerItem)
        self.player = player
        
        let layer = AVPlayerLayer(player: player)
        layer.frame = contentView.bounds
        layer.videoGravity = .resizeAspectFill
        videoContainerView.layer.insertSublayer(layer, at: 0)
        self.playerLayer = layer
        
        // 3) 내장 자막 그룹 확보
        if let asset = playerItem.asset as? AVURLAsset,
           let group = asset.mediaSelectionGroup(forMediaCharacteristic: .legible) {
            availableSubtitleOptions = group.options
        }
        
        // 4) 자막 출력용 output 연결
        let output = AVPlayerItemLegibleOutput()
        output.setDelegate(self, queue: .main)
        player.currentItem?.add(output)
        self.legibleOutput = output
        
        // 5) 옵저버 연결
        configurePlayerObservers()
    }
    
}

// MARK: - AVPlayerItemLegibleOutput Delegate
extension MainVideoCell: AVPlayerItemLegibleOutputPushDelegate {
    func legibleOutput(_ output: AVPlayerItemLegibleOutput,
                       didOutputAttributedStrings strings: [NSAttributedString],
                       nativeSampleBuffers nativeSamples: [Any],
                       forItemTime itemTime: CMTime) {
        printX(strings.first)
    }
}
