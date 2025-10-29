//
//  TastedViewerCell.swift
//  LezhinSnack
//
//  Created by 신진우 on 4/25/25.
//

import UIKit
import Alamofire
import SnapKit
import Combine
import AVFoundation
import AVKit
import PallyConFPSSDK


protocol TastedVideoCellDelegate: AnyObject {
    func tastedVideoCellDidTapMoveToMainViewer(_ cell: TastedVideoCell)
}

final class TastedVideoCell: UICollectionViewCell, VideoPlayableCell {
    
    deinit {
        cleanUp()
        printX("뷰어셀 파괴", isBoxMode: true)
    }
    
    
    //MARK: 동영상 플레이어 프로퍼티
    private var fpsSDK: PallyConFPSSDK?
    private var drmConfig: PallyConDrmConfiguration?
    
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private var timeObserverToken: Any?
    private var playerItem: AVPlayerItem?
    private var pipController: AVPictureInPictureController?
    private var legibleOutput: AVPlayerItemLegibleOutput?
    // 자막 옵션을 저장할 배열
    private var availableSubtitleOptions: [AVMediaSelectionOption] = []
    private let captionOutput = AVPlayerItemLegibleOutput()
    private var isObservingPlaybackState = true

    //MARK: UI 프로퍼티
    private var isUserInteractingWithSlider = false
    private var hasShownInitControls = false
    
    weak var delegate: VideoPlayableCellDelegate?
    
    private let videoContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(.backgroundDefault)
        return view
    }()
    
    
    private var playbackStateObserver: AnyCancellable?
    
    // 현재 배속 (기본값 1.0)
    var currentPlaybackRate: Float = 1.0
    
    
    private var statusObserver: AnyCancellable?
    
    //MARK: 우측 컨테이너 뷰
    private let rightContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    //MARK: 가운데 플레이 버튼 뷰
    let playButtonContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(.blackOpacity52)
        view.isHidden = true
        return view
    }()
    
    //MARK: 바텀 메인뷰어 이동버튼
    private let bottomButton: UIButton = {
        let button = UIButton(type: .system)
        button.layer.cornerRadius = 20
        button.clipsToBounds = true
        button.titleLabel?.font   = .pretendardSemiBold(size: 14)
        button.adjustsImageWhenHighlighted = false

        // 내부 이미지·텍스트 사이, 그리고 좌우 여백
        button.contentEdgeInsets = UIEdgeInsets(top: 0,
                                                left: 16,
                                                bottom: 0,
                                                right: 16)

        button.setImage(UIImage(named: "ic_play_fill_black"), for: .normal)
        button.tintColor = .black
        button.setTitle("1화부터 시청하기", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .white
        
        button.addTarget(self, action: #selector(moveToEpisodeButtonTapped), for: .touchUpInside)
        
        return button
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
    
    var isWishedEpisode: Bool = false {
        didSet {
            if isWishedEpisode {
                self.wishIcon.image = UIImage(named: "ic_bookmark")?.withRenderingMode(.alwaysOriginal)
            } else {
                self.wishIcon.image = UIImage(named: "ic_bookmark_fill")?.withRenderingMode(.alwaysOriginal)
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
                self.likeIcon.image = UIImage(named: "ic_heart")?.withRenderingMode(.alwaysOriginal)
            } else {
                self.likeIcon.image = UIImage(named: "ic_heart_fill")?.withRenderingMode(.alwaysOriginal)
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
        label.text = "1.5천"
        return label
    }()
    
    
    private let topContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
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
        layer.opacity = 1
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
        layer.opacity    = 1
        return layer
    }()
    
    // MARK: – 프로모션 뷰 (앞/뒤)
    private let frontPromotionView = LZSnackPromotionView(
        type: .allCases.randomElement()!
    )
    private let backPromotionView = UIView()

    private let backTagView = LZSUtil.makeTagView(type: .lezhin, tagImageSize: CGSize(width: 12, height: 12))
    private let backTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.numberOfLines = 2
        label.font = .pretendardSemiBold(size: 13)
        return label
    }()

    // MARK: – 플립 타이머와 상태
    private var flipTimer: Timer?
    private var isShowingFront = true
    
    
    private let titleImage: UIImageView = {
        let imageView = UIImageView()
        let image = UIImage(named: "mainBannerTitle")
        imageView.image = image
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .clear
        
        return imageView
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
        // 옵저버·타임토큰 해제
        flipTimer?.invalidate()
        playbackStateObserver?.cancel()
        statusObserver?.cancel()
        if let token = timeObserverToken {
            player?.removeTimeObserver(token)
            timeObserverToken = nil
        }
        player?.pause()
        player = nil
        playerLayer?.removeFromSuperlayer()
        pipController?.stopPictureInPicture()
        playerLayer = nil
        
        legibleOutput = nil
        availableSubtitleOptions.removeAll()
        
        drmConfig?.delegate = nil
        fpsSDK = nil
        drmConfig = nil
//        delegate = nil
        hasShownInitControls = false
        
        NotificationCenter.default.removeObserver(self)
        
        print("비디오 플레이어 인스턴스 해제")
    }
    
    func pausePlayer() {
        player?.pause()
    }
    
    func playPlayer() {
        player?.playImmediately(atRate: currentPlaybackRate)
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
        
        
        makeRightContainerView()
        makeTopContainerView()
        
        contentView.addSubview(playButtonContainerView)
        playButtonContainerView.snp.makeConstraints { make in
            make.width.height.equalTo(64)
            make.centerX.centerY.equalToSuperview()
        }
        playButtonContainerView.roundCorners(cornerRadius: 32)
        
        
        playButtonContainerView.addSubview(playButtonImageView)
        playButtonImageView.snp.makeConstraints { make in
            make.width.height.equalTo(32)
            make.centerX.centerY.equalToSuperview()
        }
        
        
        contentView.addSubview(bottomButton)
        bottomButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-20)
            make.height.equalTo(40)
            make.centerX.equalToSuperview()
        }
        
        videoContainerView.layer.insertSublayer(topGradientLayer, at: 0)
        videoContainerView.layer.insertSublayer(bottomGradientLayer, at: 0)
        
    }
    
    
    @objc func flipVertical() {
        promoFlipContainer.layoutIfNeeded()
        UIView.transition(
            with:       promoFlipContainer,
            duration:   0.6,
            options:    [.transitionFlipFromTop, .showHideTransitionViews],
            animations: {
                self.frontPromotionView.isHidden = self.isShowingFront
                self.backPromotionView.isHidden  = !self.isShowingFront
            },
            completion: nil
        )
        isShowingFront.toggle()
    }

    private let promoFlipContainer = UIView()
    
    private func makeTopContainerView() {
        contentView.addSubview(topContainerView)
        topContainerView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(15)
            make.height.equalTo(110)
        }
        
        topContainerView.addSubview(promoFlipContainer)
        promoFlipContainer.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(20)
        }


        // 앞면 뷰
        promoFlipContainer.addSubview(frontPromotionView)
        frontPromotionView.snp.makeConstraints { make in
            make.top.leading.equalToSuperview()
            make.height.equalTo(20)
        }

        // 뒷면 뷰
        promoFlipContainer.addSubview(backPromotionView)
        backPromotionView.snp.makeConstraints { make in
            make.top.leading.equalToSuperview()
            make.height.equalTo(20)
        }
        backPromotionView.isHidden = true

        // 뒷면 내부 구성
        backPromotionView.addSubview(backTagView)
        backTagView.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            make.width.equalTo(20)
        }
        
        backTitleLabel.textColor = .white
        backTitleLabel.text = "레진코믹스 12주간 로맨스 TOP 1 원작 웹툰"
        backPromotionView.addSubview(backTitleLabel)
        backTitleLabel.snp.makeConstraints { make in
            make.leading.equalTo(backTagView.snp.trailing).offset(8)
            make.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        
        topContainerView.addSubview(titleImage)
        titleImage.snp.makeConstraints { make in
            make.top.equalTo(promoFlipContainer.snp.bottom).offset(20)
            make.leading.equalToSuperview()
            make.height.equalTo(48)
            // 이미지가 있어야 계산되므로, 기본 비율(1:1) 대신 안전하게 최소 너비만 지정
            if let img = titleImage.image {
                make.width.equalTo(titleImage.snp.height)
                    .multipliedBy(img.size.width / img.size.height)
            } else {
                make.width.equalTo(48)  // 이미지 로드 실패 대비
            }
        }
        
        
        let testLabel = UILabel()
        testLabel.textColor = .white
        
        let attributedText = NSMutableAttributedString()
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.pretendardMedium(size: 13),
            .foregroundColor: UIColor.white
        ]
        
        let keywords = ["키워드1", "키워드2", "키워드3", "키워드4", "키워드5"]
        let keywordsString = keywords.joined(separator: " · ")
        
        attributedText.append(NSAttributedString(string: keywordsString, attributes: attributes))
        testLabel.attributedText = attributedText
        
        
        topContainerView.addSubview(testLabel)
        testLabel.snp.makeConstraints { make in
            make.height.equalTo(18)
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(titleImage.snp.bottom).offset(12)
        }

        
    }
    
    
    private func makeRightContainerView() {
        //MARK: 우측 사이드 컨테이너 뷰
        contentView.addSubview(rightContainerView)
        rightContainerView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.width.equalTo(28)
            make.height.equalTo(284)
            make.bottom.equalToSuperview().offset(-24)
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
        
        rightContainerView.addSubview(wishiConContainerView)
        wishiConContainerView.snp.makeConstraints { make in
            make.bottom.equalTo(shareContainerView.snp.top).offset(-28)
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
    
    // contentView 터치 시 호출되어 메인 플레이어의 재생/일시정지를 토글
    @objc private func contentViewTapped(_ sender: UITapGestureRecognizer) {
        // 다른 UI 컨트롤 터치와 중복되지 않도록 playPauseButton 등은 터치 이벤트가 우선 처리됨
        playPauseTapped()
    }
    
    @objc private func playPauseTapped() {
        guard let player = player else { return }
        if player.timeControlStatus == .paused {
            player.playImmediately(atRate: currentPlaybackRate)
        } else {
            player.pause()
        }
    }
    
    @objc private func backButtonTapped() {
        delegate?.videoCellDidTapBack(self)
    }
    
    @objc private func playbackDidFinish(_ notification: Notification) {
        delegate?.videoCellDidFinishPlayback(self)
    }
    
    @objc private func moveToEpisodeButtonTapped(_ sender: UIButton) {
        (delegate as? TastedVideoCellDelegate)?.tastedVideoCellDidTapMoveToMainViewer(self)
    }
    
    @objc private func likeButtonTapped(_ sender: UIButton) {
        delegate?.videoCellDidTapLikeButton(self)
    }
    
    @objc private func wishButtonTapped(_ sender: UIButton) {
        delegate?.videoCellDidTapWishButton(self)
    }
    
    @objc private func shareButtonTapped(_ sender: UIButton) {
        delegate?.videoCellDidTapShareButton(self)
    }
}

extension TastedVideoCell: PallyConFPSLicenseDelegate {
    
    func configure() {
        // HLS 스트리밍 URL (자막 메타데이터 포함)
//        guard let url = URL(string: "http://sample.vodobox.com/planete_interdite/planete_interdite_alternate.m3u8") else { return }
        // 애플 URL
//        guard let url = URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_4x3/bipbop_4x3_variant.m3u8") else { return }
        
        // 애플 URL2
//        guard let url = URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_16x9/bipbop_16x9_variant.m3u8") else { return }
        
        // 레진 스낵 DRM O
//        guard let url = URL(string: "https://d3fg9k53r6vr6z.cloudfront.net/6f043303-bc12-4c24-b565-621eecde1282/CMAF1/1min_rainandyou_1080x1920_3M_192kbps.m3u8") else { return }
        
        // 레진 스낵 DRM X
//        guard let url = URL(string: "https://d3fg9k53r6vr6z.cloudfront.net/1c5b96f0-c26f-4a90-84d4-6c8ce1b53714/CMAF1/1min_rainandyou_1080x1920_3M_192kbps.m3u8") else { return }
        
        // 레진 스낵 signedUrl
//        guard let url = URL(string: "https://d3fg9k53r6vr6z.cloudfront.net/cmaf/VIDEO/a5316ec9-c9f3-44cc-aecc-196ae9dade0a/CMAF1/1min_rainandyou_1080x1920_5M_192kbps.m3u8?Policy=eyJTdGF0ZW1lbnQiOiBbeyJSZXNvdXJjZSI6Imh0dHBzOi8vZDNmZzlrNTNyNnZyNnouY2xvdWRmcm9udC5uZXQvY21hZi9WSURFTy9hNTMxNmVjOS1jOWYzLTQ0Y2MtYWVjYy0xOTZhZTlkYWRlMGEvQ01BRjEvKiIsIkNvbmRpdGlvbiI6eyJEYXRlTGVzc1RoYW4iOnsiQVdTOkVwb2NoVGltZSI6MTc0NTk5OTcwMn19fV19&Signature=RynDLrtBH1nkQmbbdCr8cgcYqzaZPhyrqtnt0IoXw9F9Fgh2l7dY9DyLrNW4HQoZcnvTTaGmYwdHFpsWSfEA7yL4-2ZhP7LeIt-gJRwrLF-kklRbyaCwN9zmyzqY5X31HF2wpqUb5xxGfrAbowcRLFY2HzNzLO6aEnyJRb4ltrof4PaUwlplGMaC4ZlFMPybIbEC61WdRGt~NTUymEbjg6hr234q9eiUxEUOR--p-L2oCz36zwzRwSnpIYVCYQC3AUffMs8lXbKQ1Sd--YuV8xA0h4HDATPRYsJrBRFJA~-c5EYUh-c3ybleYQih-qZLF6cCObY1klE-TE5~bHbIeg__&Key-Pair-Id=K2QQMVLCVN7V12") else { return }
        
        // 레진 스낵 signedUrl, DRM O
//        guard let url = URL(string: "https://d3fg9k53r6vr6z.cloudfront.net/cmaf/DRM_VIDEO/6aa77ecc-a02c-4fd5-af03-70e2fae39b4d/CMAF1/1min_rainandyou_1080x1920_3M_192kbps.m3u8?Policy=eyJTdGF0ZW1lbnQiOiBbeyJSZXNvdXJjZSI6Imh0dHBzOi8vZDNmZzlrNTNyNnZyNnouY2xvdWRmcm9udC5uZXQvY21hZi9EUk1fVklERU8vNmFhNzdlY2MtYTAyYy00ZmQ1LWFmMDMtNzBlMmZhZTM5YjRkL0NNQUYxLyoiLCJDb25kaXRpb24iOnsiRGF0ZUxlc3NUaGFuIjp7IkFXUzpFcG9jaFRpbWUiOjE3NTM1OTYxMzh9fX1dfQ__&Signature=J0gRp3ltTpxadipfWZCPMVig3C7pGjFyEEEzwKfl4FE5WVbqfhrN5tgbz3euWLCCIEE0FpgpBnaO2PDysFGWQRsk1ZCUwM1ePoKcXr9E4wCjixLYIFsLCv~bTfZrQItkZGsbDEueQgrhGeQYa-qcZFgAJGELziLs0hfGVJh66rzXan4x5T~XgEVcaXut2kTgSgRhR1bYToqnXG5z2QzzDiIN4637Kvz1HT26THEgw8o8mTDKG5vW~l2XD7v2TBgF5O8V7Z2ero5NTbk3nGoHe2Ej~VOEvsl9PgkfWkWBOpEKgkFNaIEjcIIFGrXjx6d63A31uYRJ~NDTPbauj3iYIw__&Key-Pair-Id=K2QQMVLCVN7V12") else { return }
        
        
        // 목업 로컬 더미 비디오
        guard let url = Bundle.main.url(forResource: "dummy_video", withExtension: "mp4") else { return }
        
//        let asset = AVURLAsset(url: url)
        
        let certificateUrl = "https://license-global.pallycon.com/ri/fpsKeyManager.do?siteId=UVOO"
        let contentId      = "13891728"
        let pallyconToken  = "eyJrZXlfcm90YXRpb24iOmZhbHNlLCJyZXNwb25zZV9mb3JtYXQiOiJvcmlnaW5hbCIsInVzZXJfaWQiOiI1NDEyMyIsImRybV90eXBlIjoiRmFpclBsYXkiLCJzaXRlX2lkIjoiVVZPTyIsImhhc2giOiJqUlFlbU9tN2lQSkxFNERENHBnUWRsZ1dwQU1UZHlpK1FVUkRhMGJIUWw4PSIsImNpZCI6IjEzODkxNzI4IiwicG9saWN5IjoicVF0aXp2UHBBQWxndHgxeDNPNlQwWHpoT3FvOG9aOXJSSmFQQXpQNnc4MD0iLCJ0aW1lc3RhbXAiOiIyMDI1LTA0LTI4VDEyOjQ2OjMyWiJ9"
        
        FairPlayStreamManager.shared.prepareDRM(
            for: contentId,
            url: url,
            token: pallyconToken
        )

        // 2) 재사용 가능한 AVPlayerItem 가져오기
        playerItem = FairPlayStreamManager.shared.playerItem(
            for: contentId
        )
        player = AVPlayer(playerItem: playerItem)
        
//        videoContainerView.makeSecure()
        
//        playerItem = AVPlayerItem(asset: asset)
//        player = AVPlayer(playerItem: playerItem)
        
        // AVPlayerLayer 생성 및 셀의 contentView에 추가
        playerLayer = AVPlayerLayer(player: player)
        guard let playerLayer = playerLayer else { return }
        playerLayer.frame = contentView.bounds
        playerLayer.videoGravity = .resizeAspectFill
        videoContainerView.layer.insertSublayer(playerLayer, at: 0)
//        contentView.layer.insertSublayer(playerLayer, at: 0)
        
        // 자막 옵션 비동기 로드 및 선택 (UI에서 선택 가능하도록 옵션 저장)
//        let key = "availableMediaCharacteristicsWithMediaSelectionOptions"
//        asset.loadValuesAsynchronously(forKeys: [key]) { [weak self] in
//            var error: NSError?
//            let status = asset.statusOfValue(forKey: key, error: &error)
//
//            DispatchQueue.main.async {
//                if status == .loaded {
//                    if let legibleGroup = asset.mediaSelectionGroup(forMediaCharacteristic: .legible),
//                       !legibleGroup.options.isEmpty {
//                        self?.availableSubtitleOptions = legibleGroup.options
//                        // 기본 자막으로 첫 번째 옵션 선택 (원하는 경우 변경 가능)
//                        self?.playerItem?.select(self?.availableSubtitleOptions.first, in: legibleGroup)
//                        print("자막 트랙 선택됨: \(self?.availableSubtitleOptions.first?.displayName ?? "None"), locale: \(self?.availableSubtitleOptions.first?.locale?.identifier ?? "none")")
//                    } else {
//                        print("자막 트랙이 없습니다.")
//                    }
//                } else {
//                    print("자막 정보를 불러오지 못했습니다. 오류: \(error?.localizedDescription ?? "Unknown error")")
//                }
//            }
//        }
        
        // 자막(legible) 출력용 AVPlayerItemLegibleOutput 설정
        let output = AVPlayerItemLegibleOutput()
        output.setDelegate(self, queue: DispatchQueue.main)
        player?.currentItem?.add(output)
        legibleOutput = output
        
        
        configurePlayerObservers()
        
        flipTimer = Timer.scheduledTimer(
            timeInterval: 2.0,
            target: self,
            selector: #selector(flipVertical),
            userInfo: nil,
            repeats: true
        )
        
    }
    
    private func setViewerSubViews(isPlay: Bool) {
        self.playButtonContainerView.isHidden = isPlay
    }
    

    func configurePlayerObservers() {
        guard let player = player,
              let item = player.currentItem else { return }
        
        playbackStateObserver = player
            .publisher(for: \.timeControlStatus)
            .debounce(for: .milliseconds(100), scheduler: RunLoop.main)
            .sink { [weak self] status in
                guard let self = self else { return }
                self.setViewerSubViews(isPlay: status == .playing)
            }
        
        statusObserver = item.publisher(for: \.status)
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
                        print("""
                        ▶️ 재생 실패 감지:
                          • 도메인: \(error.domain)
                          • 코드: \(error.code)
                          • 설명: \(error.localizedDescription)
                        """)
                    } else {
                        print("▶️ 재생 실패: 상세 오류 정보 없음")
                    }
                default:
                    break
                }
            }
        
        timeObserverToken = player.addPeriodicTimeObserver(
            forInterval: CMTime(seconds: 0.5, preferredTimescale: 600),
            queue: .main
        ) { [weak self] time in
            guard let self = self,
                  let duration = player.currentItem?.duration,
                  !self.isUserInteractingWithSlider else { return }
            
            let currentSeconds = CMTimeGetSeconds(time)
            let totalSeconds   = CMTimeGetSeconds(duration)
            guard totalSeconds.isFinite && totalSeconds > 0 else { return }
            
        }
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playbackDidFinish(_:)),
            name: .AVPlayerItemDidPlayToEndTime,
            object: playerItem
        )
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


// MARK: - AVPlayerItemLegibleOutput Delegate
extension TastedVideoCell: AVPlayerItemLegibleOutputPushDelegate {
    func legibleOutput(_ output: AVPlayerItemLegibleOutput,
                       didOutputAttributedStrings strings: [NSAttributedString],
                       nativeSampleBuffers nativeSamples: [Any],
                       forItemTime itemTime: CMTime) {
//        printX(strings.first)
    }
}
