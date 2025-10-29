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


final class PromotionVideoCell: UICollectionViewCell, VideoPlayableCell {
    
    deinit {
        cleanUp()
        printX("뷰어셀 파괴", isBoxMode: true)
    }
    
    private var fpsSDK: PallyConFPSSDK?
    private var drmConfig: PallyConDrmConfiguration?
    
    var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private var timeObserverToken: Any?
    var playerItem: AVPlayerItem?
    private var pipController: AVPictureInPictureController?
    
    private var isUserInteractingWithSlider = false
    
    private var legibleOutput: AVPlayerItemLegibleOutput?
    // 자막 옵션을 저장할 배열
    private var availableSubtitleOptions: [AVMediaSelectionOption] = []
    
    private let captionOutput = AVPlayerItemLegibleOutput()
    
    private var isObservingPlaybackState = true
    private var hasShownInitControls = false
    
    weak var delegate: VideoPlayableCellDelegate?
    
    private let videoContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(.backgroundDefault)
        return view
    }()
    
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
    
    //MARK: 가운데 플레이 버튼 뷰
    let playButtonContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(.blackOpacity52)
        return view
    }()
    
    
    let playButtonImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "ic_play_fill"))
        imageView.backgroundColor = .clear
        imageView.contentMode = .scaleAspectFit
        return imageView
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
    
    private let wishIcon: UIImageView = {
        UIImageView(image: UIImage(named: "ic_bookmark")?.withRenderingMode(.alwaysOriginal))
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
    
    
    private let likeIcon: UIImageView = {
        UIImageView(image: UIImage(named: "ic_heart")?.withRenderingMode(.alwaysOriginal))
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
        // 옵저버·타임토큰 해제
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
        seekSlider.value = 0
        
        drmConfig?.delegate = nil
        fpsSDK = nil
        drmConfig = nil
        delegate = nil
        hasShownInitControls = false
        
        NotificationCenter.default.removeObserver(self)
        
        print("비디오 플레이어 인스턴스 해제")
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
        isObservingPlaybackState = false
        
        [bottomControlsContainerView,
         rightContainerView,
         playButtonContainerView,
         topContainerView].forEach { $0.alpha = 1 }
        
        onMainAfter(delay: 3) {
            UIView.animate(withDuration: 0.3) {
                [self.bottomControlsContainerView,
                 self.rightContainerView,
                 self.playButtonContainerView,
                 self.topContainerView].forEach { $0.alpha = 0 }
            } completion: { _ in
                self.isObservingPlaybackState = true
            }
        }
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
        
        topEpisodeTitleLabel.text = "마녀 29세"
        
        topInnerTitleContainerView.addSubview(episodeCountLabel)
        episodeCountLabel.snp.makeConstraints { make in
            make.top.equalTo(topEpisodeTitleLabel.snp.bottom)
            make.leading.equalToSuperview()
        }
        
        episodeCountLabel.text = "2/48"
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
        
        rightContainerView.addSubview(shareLabel)
        shareLabel.snp.makeConstraints { make in
            make.bottom.leading.trailing.equalToSuperview()
            make.height.equalTo(18)
        }
        
        rightContainerView.addSubview(shareIcon)
        shareIcon.snp.makeConstraints { make in
            make.bottom.equalTo(shareLabel.snp.top).offset(-4)
            make.height.equalTo(28)
            make.leading.trailing.equalToSuperview()
        }
        
        rightContainerView.addSubview(listLabel)
        listLabel.snp.makeConstraints { make in
            make.bottom.equalTo(shareIcon.snp.top).offset(-28)
            make.height.equalTo(18)
            make.leading.trailing.equalToSuperview()
        }
        
        rightContainerView.addSubview(listIcon)
        listIcon.snp.makeConstraints { make in
            make.bottom.equalTo(listLabel.snp.top).offset(-4)
            make.height.equalTo(28)
            make.leading.trailing.equalToSuperview()
        }
        
        rightContainerView.addSubview(wishLabel)
        wishLabel.snp.makeConstraints { make in
            make.bottom.equalTo(listIcon.snp.top).offset(-28)
            make.height.equalTo(18)
            make.leading.trailing.equalToSuperview()
        }
        
        rightContainerView.addSubview(wishIcon)
        wishIcon.snp.makeConstraints { make in
            make.bottom.equalTo(wishLabel.snp.top).offset(-4)
            make.height.equalTo(28)
            make.leading.trailing.equalToSuperview()
        }
        
        rightContainerView.addSubview(likeLabel)
        likeLabel.snp.makeConstraints { make in
            make.bottom.equalTo(wishIcon.snp.top).offset(-28)
            make.height.equalTo(18)
            make.leading.trailing.equalToSuperview()
        }
        
        rightContainerView.addSubview(likeIcon)
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
             self.playButtonContainerView,
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
        delegate?.videoCell(self,
                            didTapSubtitleButton: sender,
                            availableOptions: availableSubtitleOptions)
    }
    
    @objc private func playbackDidFinish(_ notification: Notification) {
        delegate?.videoCellDidFinishPlayback(self)
    }
}

extension PromotionVideoCell: PallyConFPSLicenseDelegate {
    
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
        
        // 레진 스낵 signedUrl, DRM X
//        guard let url = URL(string: "https://d3fg9k53r6vr6z.cloudfront.net/cmaf/VIDEO/a5316ec9-c9f3-44cc-aecc-196ae9dade0a/CMAF1/1min_rainandyou_1080x1920_5M_192kbps.m3u8?Policy=eyJTdGF0ZW1lbnQiOiBbeyJSZXNvdXJjZSI6Imh0dHBzOi8vZDNmZzlrNTNyNnZyNnouY2xvdWRmcm9udC5uZXQvY21hZi9WSURFTy9hNTMxNmVjOS1jOWYzLTQ0Y2MtYWVjYy0xOTZhZTlkYWRlMGEvQ01BRjEvKiIsIkNvbmRpdGlvbiI6eyJEYXRlTGVzc1RoYW4iOnsiQVdTOkVwb2NoVGltZSI6MTc0NTk5OTcwMn19fV19&Signature=RynDLrtBH1nkQmbbdCr8cgcYqzaZPhyrqtnt0IoXw9F9Fgh2l7dY9DyLrNW4HQoZcnvTTaGmYwdHFpsWSfEA7yL4-2ZhP7LeIt-gJRwrLF-kklRbyaCwN9zmyzqY5X31HF2wpqUb5xxGfrAbowcRLFY2HzNzLO6aEnyJRb4ltrof4PaUwlplGMaC4ZlFMPybIbEC61WdRGt~NTUymEbjg6hr234q9eiUxEUOR--p-L2oCz36zwzRwSnpIYVCYQC3AUffMs8lXbKQ1Sd--YuV8xA0h4HDATPRYsJrBRFJA~-c5EYUh-c3ybleYQih-qZLF6cCObY1klE-TE5~bHbIeg__&Key-Pair-Id=K2QQMVLCVN7V12") else { return }
        
        // 레진 스낵 signedUrl, DRM O
        guard let url = URL(string: "https://d3fg9k53r6vr6z.cloudfront.net/cmaf/DRM_VIDEO/6aa77ecc-a02c-4fd5-af03-70e2fae39b4d/CMAF1/1min_rainandyou_1080x1920_3M_192kbps.m3u8?Policy=eyJTdGF0ZW1lbnQiOiBbeyJSZXNvdXJjZSI6Imh0dHBzOi8vZDNmZzlrNTNyNnZyNnouY2xvdWRmcm9udC5uZXQvY21hZi9EUk1fVklERU8vNmFhNzdlY2MtYTAyYy00ZmQ1LWFmMDMtNzBlMmZhZTM5YjRkL0NNQUYxLyoiLCJDb25kaXRpb24iOnsiRGF0ZUxlc3NUaGFuIjp7IkFXUzpFcG9jaFRpbWUiOjE3NTM1OTYxMzh9fX1dfQ__&Signature=J0gRp3ltTpxadipfWZCPMVig3C7pGjFyEEEzwKfl4FE5WVbqfhrN5tgbz3euWLCCIEE0FpgpBnaO2PDysFGWQRsk1ZCUwM1ePoKcXr9E4wCjixLYIFsLCv~bTfZrQItkZGsbDEueQgrhGeQYa-qcZFgAJGELziLs0hfGVJh66rzXan4x5T~XgEVcaXut2kTgSgRhR1bYToqnXG5z2QzzDiIN4637Kvz1HT26THEgw8o8mTDKG5vW~l2XD7v2TBgF5O8V7Z2ero5NTbk3nGoHe2Ej~VOEvsl9PgkfWkWBOpEKgkFNaIEjcIIFGrXjx6d63A31uYRJ~NDTPbauj3iYIw__&Key-Pair-Id=K2QQMVLCVN7V12") else { return }
        
        
        // 목업 로컬 더미 비디오
        guard let url = Bundle.main.url(forResource: "dummy_video", withExtension: "mp4") else { return }
        
        let asset = AVURLAsset(url: url)
        
        let certificateUrl = "https://license-global.pallycon.com/ri/fpsKeyManager.do?siteId=UVOO"
        let contentId      = "13891728"
        let pallyconToken  = "eyJrZXlfcm90YXRpb24iOmZhbHNlLCJyZXNwb25zZV9mb3JtYXQiOiJvcmlnaW5hbCIsInVzZXJfaWQiOiI3NDc0IiwiZHJtX3R5cGUiOiJGaWFyUGxheSAvIFdpZGV2aW5lIiwic2l0ZV9pZCI6IlVWT08iLCJoYXNoIjoiRjVYK0taWUxUK3VCMXRFeXVZTVA3S0dzWjl3dXVDQmRVNVZHTDBGVjA3Zz0iLCJjaWQiOiIxMzg5MTcyOCIsInBvbGljeSI6InFRdGl6dlBwQUFsZ3R4MXgzTzZUMFh6aE9xbzhvWjlyUkphUEF6UDZ3ODA9IiwidGltZXN0YW1wIjoiMjAyNS0wNC0yOFQwNzozNTowNVoifQ=="
        
        drmConfig = PallyConDrmConfiguration(avURLAsset: asset,
                                             contentId: contentId,
                                             certificateUrl: certificateUrl,
                                             authData: pallyconToken)
        drmConfig?.delegate = self
        // 2. Acquire a CustomData information
        
        fpsSDK = PallyConFPSSDK()
        
        if let fpsSDK, let drmConfig {
            fpsSDK.prepare(Content: drmConfig)
        }
        
//        videoContainerView.makeSecure()
        
        playerItem = AVPlayerItem(asset: asset)
        player = AVPlayer(playerItem: playerItem)
        
        // AVPlayerLayer 생성 및 셀의 contentView에 추가
        playerLayer = AVPlayerLayer(player: player)
        guard let playerLayer = playerLayer else { return }
        playerLayer.frame = contentView.bounds
        playerLayer.videoGravity = .resizeAspectFill
        videoContainerView.layer.insertSublayer(playerLayer, at: 0)
//        contentView.layer.insertSublayer(playerLayer, at: 0)
        
        // 자막 옵션 비동기 로드 및 선택 (UI에서 선택 가능하도록 옵션 저장)
        let key = "availableMediaCharacteristicsWithMediaSelectionOptions"
        asset.loadValuesAsynchronously(forKeys: [key]) { [weak self] in
            var error: NSError?
            let status = asset.statusOfValue(forKey: key, error: &error)
            
            DispatchQueue.main.async {
                if status == .loaded {
                    if let legibleGroup = asset.mediaSelectionGroup(forMediaCharacteristic: .legible),
                       !legibleGroup.options.isEmpty {
                        self?.availableSubtitleOptions = legibleGroup.options
                        // 기본 자막으로 첫 번째 옵션 선택 (원하는 경우 변경 가능)
                        self?.playerItem?.select(self?.availableSubtitleOptions.first, in: legibleGroup)
                        print("자막 트랙 선택됨: \(self?.availableSubtitleOptions.first?.displayName ?? "None"), locale: \(self?.availableSubtitleOptions.first?.locale?.identifier ?? "none")")
                    } else {
                        print("자막 트랙이 없습니다.")
                    }
                } else {
                    print("자막 정보를 불러오지 못했습니다. 오류: \(error?.localizedDescription ?? "Unknown error")")
                }
            }
        }
        
        // 자막(legible) 출력용 AVPlayerItemLegibleOutput 설정
        let output = AVPlayerItemLegibleOutput()
        output.setDelegate(self, queue: DispatchQueue.main)
        player?.currentItem?.add(output)
        legibleOutput = output
        
//        player?.play()
        
        configurePlayerObservers()
        
        
    }
    

    func configurePlayerObservers() {
        guard let player = player,
              let item = player.currentItem else { return }
        
        playbackStateObserver = player
            .publisher(for: \.timeControlStatus)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                guard let self = self,
                      self.isObservingPlaybackState else { return }
                self.setViewerSubViews(isPlay: status == .playing)
            }
        
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
            
            self.seekSlider.value = Float(currentSeconds / totalSeconds)
            self.setPauseTimeLabelText()
        }
        
        // 4) 슬라이더 터치 상태 변화 처리
        seekSlider.addTarget(self, action: #selector(self.sliderTouchDown), for: .touchDown)
        seekSlider.addTarget(self, action: #selector(self.sliderTouchUp),   for: [.touchUpInside, .touchUpOutside, .touchCancel])
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playbackDidFinish(_:)),
            name: .AVPlayerItemDidPlayToEndTime,
            object: playerItem
        )
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


// MARK: - AVPlayerItemLegibleOutput Delegate
extension PromotionVideoCell: AVPlayerItemLegibleOutputPushDelegate {
    func legibleOutput(_ output: AVPlayerItemLegibleOutput,
                       didOutputAttributedStrings strings: [NSAttributedString],
                       nativeSampleBuffers nativeSamples: [Any],
                       forItemTime itemTime: CMTime) {
//        printX(strings.first)
    }
}
