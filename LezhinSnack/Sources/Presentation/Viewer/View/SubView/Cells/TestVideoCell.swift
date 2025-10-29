import UIKit
import Alamofire
import SnapKit
import Combine
import AVFoundation
import AVKit
import PallyConFPSSDK


let certificateURLString = "https://license-global.pallycon.com/ri/fpsKeyManager.do?siteId=UVOO"
let contentId      = "testcontent"
let requestURI  = "https://license-global.pallycon.com/ri/licenseManager.do"

final class TestVideoCell: UICollectionViewCell, VideoPlayableCell {
    
    var delegate: VideoPlayableCellDelegate?
    
    
    static let identifier = "VideoPlayerCell"
    
    
    let fpsSDK = PallyConFPSSDK()
    
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private var timeObserverToken: Any?
    private var playerItem: AVPlayerItem?
    private var pipController: AVPictureInPictureController?
    
    private var isUserInteractingWithSlider = false
    
    // 썸네일 관련 코드
    private var thumbnailPlayer: AVPlayer?
    private var thumbnailPlayerLayer: AVPlayerLayer?
    // 썸네일 플레이어가 현재 seek 중인지 여부
    private var isThumbnailSeekInProgress = false
    // 마지막에 실제 seek가 완료된 시간을 저장
    private var lastThumbnailSeekTime: CMTime?
    // 진행 중인 seek가 있으면 마지막으로 요청된 seek 시간을 저장
    private var pendingThumbnailSeekTime: CMTime?
    
    // 썸네일 미리보기를 위한 컨테이너 뷰
    private let thumbnailView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(.backgroundDefault)
        view.isHidden = true  // 터치 시에만 보이도록 함
        return view
    }()
    
    private var legibleOutput: AVPlayerItemLegibleOutput?
    // 자막 옵션을 저장할 배열
    private var availableSubtitleOptions: [AVMediaSelectionOption] = []
    
    let captionOutput = AVPlayerItemLegibleOutput()
    
    private let playPauseButton = UIButton(type: .system)
    private let seekSlider = UISlider()
    private let speedControlSegmentedControl = UISegmentedControl(items: ["0.5x", "1x", "1.5x", "2x"])
    
    private let pipButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("PIP", for: .normal)
        return button
    }()
    
    // 자막 선택 버튼
    private let subtitleButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("자막", for: .normal)
        return button
    }()
    
    // 현재 배속 (기본값 1.0)
    private var currentPlaybackRate: Float = 1.0
    
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
        if let token = timeObserverToken {
            player?.removeTimeObserver(token)
            timeObserverToken = nil
        }
        player?.pause()
        player = nil
        playerLayer?.removeFromSuperlayer()
        pipController?.stopPictureInPicture()
        playerLayer = nil
        
        thumbnailPlayer?.pause()
        thumbnailPlayer = nil
        thumbnailPlayerLayer?.removeFromSuperlayer()
        thumbnailPlayerLayer = nil
        isThumbnailSeekInProgress = false
        pendingThumbnailSeekTime = nil
        
        legibleOutput = nil
        availableSubtitleOptions.removeAll()
        seekSlider.value = 0
        thumbnailView.isHidden = true
        
        print("비디오 플레이어 인스턴스 해제")
    }
    
    func resetPlayer() {
        player?.pause()
        player?.seek(to: .zero)
    }
    
    func playPlayer() {
        player?.playImmediately(atRate: currentPlaybackRate)
    }
    
    func pausePlayer() {
        player?.pause()
    }
    
    func configure() {
        // HLS 스트리밍 URL (자막 메타데이터 포함)
//        guard let url = URL(string: "http://sample.vodobox.com/planete_interdite/planete_interdite_alternate.m3u8") else { return }
        
        // 애플 URL
//        guard let url = URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_4x3/bipbop_4x3_variant.m3u8") else { return }
        
        
//        guard let url = URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_4x3/bipbop_4x3_variant.m3u8") else { return }
        
        
        
        
        // 레진 스낵 DRM O
//        guard let url = URL(string: "https://d3fg9k53r6vr6z.cloudfront.net/6f043303-bc12-4c24-b565-621eecde1282/CMAF1/1min_rainandyou_1080x1920_3M_192kbps.m3u8") else { return }
        
        // 레진 스낵 DRM X
//        guard let url = URL(string: "https://d3fg9k53r6vr6z.cloudfront.net/cmaf/VIDEO/a5316ec9-c9f3-44cc-aecc-196ae9dade0a/CMAF1/1min_rainandyou_1080x1920_5M_192kbps.m3u8?Policy=eyJTdGF0ZW1lbnQiOiBbeyJSZXNvdXJjZSI6Imh0dHBzOi8vZDNmZzlrNTNyNnZyNnouY2xvdWRmcm9udC5uZXQvY21hZi9WSURFTy9hNTMxNmVjOS1jOWYzLTQ0Y2MtYWVjYy0xOTZhZTlkYWRlMGEvQ01BRjEvKiIsIkNvbmRpdGlvbiI6eyJEYXRlTGVzc1RoYW4iOnsiQVdTOkVwb2NoVGltZSI6MTc0NTk5OTcwMn19fV19&Signature=RynDLrtBH1nkQmbbdCr8cgcYqzaZPhyrqtnt0IoXw9F9Fgh2l7dY9DyLrNW4HQoZcnvTTaGmYwdHFpsWSfEA7yL4-2ZhP7LeIt-gJRwrLF-kklRbyaCwN9zmyzqY5X31HF2wpqUb5xxGfrAbowcRLFY2HzNzLO6aEnyJRb4ltrof4PaUwlplGMaC4ZlFMPybIbEC61WdRGt~NTUymEbjg6hr234q9eiUxEUOR--p-L2oCz36zwzRwSnpIYVCYQC3AUffMs8lXbKQ1Sd--YuV8xA0h4HDATPRYsJrBRFJA~-c5EYUh-c3ybleYQih-qZLF6cCObY1klE-TE5~bHbIeg__&Key-Pair-Id=K2QQMVLCVN7V12") else { return }
        
        
        // 레진 스낵 signedUrl
        guard let url = URL(string: "https://d3fg9k53r6vr6z.cloudfront.net/cmaf/VIDEO/a5316ec9-c9f3-44cc-aecc-196ae9dade0a/CMAF1/1min_rainandyou_1080x1920_5M_192kbps.m3u8?Policy=eyJTdGF0ZW1lbnQiOiBbeyJSZXNvdXJjZSI6Imh0dHBzOi8vZDNmZzlrNTNyNnZyNnouY2xvdWRmcm9udC5uZXQvY21hZi9WSURFTy9hNTMxNmVjOS1jOWYzLTQ0Y2MtYWVjYy0xOTZhZTlkYWRlMGEvQ01BRjEvKiIsIkNvbmRpdGlvbiI6eyJEYXRlTGVzc1RoYW4iOnsiQVdTOkVwb2NoVGltZSI6MTc0NjE1ODkyM319fV19&Signature=CLnfG6JS6kAAiHhztvERPHCR971zVekpZjMLptaxtJp1vEvJK2GAvsCd9PWHaoz~3XaYNNmJmyV-JAtcnHXt-w6g-CIvc5vw1cAvn3Y~KjgTu2vPORUNtJGxamBv2r79Cygh9QdRNy3G1KrO-5FEL63Saf1uK8LMprrrvRN5S35PPfi~UOQ7vdOtG89oqECLlbdu7UcY~hAdjttPNWBiHWQPEtIEVRqQmafQUaGEd2KZrEM-fU9Qw0sW25dsyOS~s1S2i-ukfjLVT1a2ixQFGEMA~gompA0ejmQoEfBK2uRIYTVTs5KjadfDbF4nHkWFPXpmz1HM6GJfwPFuSTyGHg__&Key-Pair-Id=K2QQMVLCVN7V12") else { return }
        
        
        let asset = AVURLAsset(url: url)
        
        let certificateUrl = "https://license-global.pallycon.com/ri/fpsKeyManager.do?siteId=UVOO"
        let contentId      = "makesnack"
        let pallyconToken  = "eyJrZXlfcm90YXRpb24iOnRydWUsInJlc3BvbnNlX2Zvcm1hdCI6Im9yaWdpbmFsIiwidXNlcl9pZCI6IjEyMzEyMyIsImRybV90eXBlIjoiRmlhclBsYXksV2lkZXZpbmUiLCJzaXRlX2lkIjoiVVZPTyIsImhhc2giOiJ4Kzh0dVhhRkxTYlk4cmhBVmF4ZTNjbGxrYXJhZWg3dENqU2x4WWczZGkwPSIsImNpZCI6Im1ha2VzbmFjayIsInBvbGljeSI6InFRdGl6dlBwQUFsZ3R4MXgzTzZUMFh6aE9xbzhvWjlyUkphUEF6UDZ3ODA9IiwidGltZXN0YW1wIjoiMjAyNS0wNC0yM1QwNTo1NTo0NVoifQ=="
        
        let config = PallyConDrmConfiguration(avURLAsset: asset,
                                              contentId: contentId,
                                              certificateUrl: certificateUrl,
                                              authData: pallyconToken )
        
        config.delegate = self
        // 2. Acquire a CustomData information
        fpsSDK.prepare(Content: config)
        
        playerItem = AVPlayerItem(asset: asset)
        player = AVPlayer(playerItem: playerItem)
        
        // AVPlayerLayer 생성 및 셀의 contentView에 추가
        playerLayer = AVPlayerLayer(player: player)
        guard let playerLayer = playerLayer else { return }
        playerLayer.frame = contentView.bounds
        playerLayer.videoGravity = .resizeAspect
        contentView.layer.insertSublayer(playerLayer, at: 0)
        
        // PIP 컨트롤러 생성
        if AVPictureInPictureController.isPictureInPictureSupported() {
            pipController = AVPictureInPictureController(playerLayer: playerLayer)
            pipController?.delegate = self
        }
        
        addPeriodicTimeObserver()
        
        // 자막 옵션 비동기 로드 및 선택 (UI에서 선택 가능하도록 옵션 저장)
        let key = "availableMediaCharacteristicsWithMediaSelectionOptions"
        asset.loadValuesAsynchronously(forKeys: [key]) {
            var error: NSError?
            let status = asset.statusOfValue(forKey: key, error: &error)
            
            DispatchQueue.main.async {
                if status == .loaded {
                    if let legibleGroup = asset.mediaSelectionGroup(forMediaCharacteristic: .legible),
                       !legibleGroup.options.isEmpty {
                        self.availableSubtitleOptions = legibleGroup.options
                        // 기본 자막으로 첫 번째 옵션 선택 (원하는 경우 변경 가능)
                        self.playerItem?.select(self.availableSubtitleOptions.first, in: legibleGroup)
                        print("자막 트랙 선택됨: \(self.availableSubtitleOptions.first?.displayName ?? "None"), locale: \(self.availableSubtitleOptions.first?.locale?.identifier ?? "none")")
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
        
        let thumbnailPlayerItem = AVPlayerItem(asset: asset)
//        thumbnailPlayerItem.preferredPeakBitRate = 200000 // 200,000bps
        
        thumbnailPlayer = AVPlayer(playerItem: thumbnailPlayerItem)
        // 썸네일 플레이어는 재생상태를 0(멈춤)으로 유지
        thumbnailPlayer?.rate = 0
        
        thumbnailPlayerLayer = AVPlayerLayer(player: thumbnailPlayer)
        thumbnailPlayerLayer?.videoGravity = .resizeAspect
        if let thumbnailPlayerLayer = thumbnailPlayerLayer {
            thumbnailView.layer.addSublayer(thumbnailPlayerLayer)
            thumbnailPlayerLayer.frame = thumbnailView.bounds
            
            thumbnailView.layoutIfNeeded()
        }
    }
    
    private func setupUI() {
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(contentViewTapped(_:)))
        // 다른 UI 컨트롤(버튼, 슬라이더 등)이 터치 이벤트를 먼저 처리할 수 있도록 설정
        tapGesture.cancelsTouchesInView = false
        contentView.addGestureRecognizer(tapGesture)
        
        // 플레이/일시정지 버튼
        playPauseButton.setTitle("Play", for: .normal)
        playPauseButton.addTarget(self, action: #selector(playPauseTapped), for: .touchUpInside)
        contentView.addSubview(playPauseButton)
        playPauseButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(8)
            make.top.equalToSuperview().offset(8)
            make.width.equalTo(50)
            make.height.equalTo(30)
        }
        
        // 배속 조절 컨트롤
        speedControlSegmentedControl.selectedSegmentIndex = 1 // 기본 1x
        speedControlSegmentedControl.addTarget(self, action: #selector(speedControlChanged(_:)), for: .valueChanged)
        contentView.addSubview(speedControlSegmentedControl)
        speedControlSegmentedControl.snp.makeConstraints { make in
            make.leading.equalTo(playPauseButton.snp.trailing).offset(8)
            make.centerY.equalTo(playPauseButton.snp.centerY)
            make.trailing.equalToSuperview().offset(-8)
            make.height.equalTo(30)
        }
        
        // 탐색 슬라이더
        seekSlider.isContinuous = true
        seekSlider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
        // 슬라이더 터치 이벤트: 시작과 종료 시 썸네일 뷰 표시/숨김
        seekSlider.addTarget(self, action: #selector(sliderTouchDown(_:)), for: .touchDown)
        seekSlider.addTarget(self, action: #selector(sliderTouchUp(_:)), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        contentView.addSubview(seekSlider)
        seekSlider.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(8)
            make.trailing.equalToSuperview().offset(-8)
            make.bottom.equalToSuperview().offset(-8)
            make.height.equalTo(30)
        }
        
        // PIP 버튼
        contentView.addSubview(pipButton)
        pipButton.addTarget(self, action: #selector(pipButtonTapped), for: .touchUpInside)
        pipButton.snp.makeConstraints { make in
            make.top.equalTo(speedControlSegmentedControl.snp.bottom).offset(16)
            make.trailing.equalToSuperview().offset(-8)
            make.width.equalTo(50)
            make.height.equalTo(30)
        }
        
        // 자막 선택 버튼 (PIP 버튼 왼쪽에 배치)
        contentView.addSubview(subtitleButton)
        subtitleButton.addTarget(self, action: #selector(subtitleButtonTapped), for: .touchUpInside)
        subtitleButton.snp.makeConstraints { make in
            make.top.equalTo(speedControlSegmentedControl.snp.bottom).offset(16)
            make.trailing.equalTo(pipButton.snp.leading).offset(-8)
            make.width.equalTo(60)
            make.height.equalTo(30)
        }
        
        // 썸네일 뷰: 슬라이더 위에 배치
        contentView.addSubview(thumbnailView)
        thumbnailView.backgroundColor = UIColor(.backgroundDefault)
        thumbnailView.snp.makeConstraints { make in
            make.bottom.equalTo(seekSlider.snp.top).offset(-8)
            make.centerX.equalTo(seekSlider)
            make.width.equalTo(120)
            make.height.equalTo(68)
        }
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
            playPauseButton.setTitle("Pause", for: .normal)
        } else {
            player.pause()
            playPauseButton.setTitle("Play", for: .normal)
        }
    }
    
    @objc private func speedControlChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            currentPlaybackRate = 0.5
        case 1:
            currentPlaybackRate = 1.0
        case 2:
            currentPlaybackRate = 1.5
        case 3:
            currentPlaybackRate = 2.0
        default:
            currentPlaybackRate = 1.0
        }
        if let player = player, player.timeControlStatus != .paused {
            player.rate = currentPlaybackRate
        }
        print("현재 배속: \(currentPlaybackRate)x")
    }
    
    // 터치 중(slider valueChanged): 썸네일 플레이어 업데이트 + pending seek 처리
    @objc private func sliderValueChanged(_ sender: UISlider) {
        guard let duration = player?.currentItem?.duration else { return }
        let totalSeconds = CMTimeGetSeconds(duration)
        
        // 슬라이더의 값 정규화 및 타겟 시간 계산
        let normalizedValue = (sender.value - sender.minimumValue) / (sender.maximumValue - sender.minimumValue)
        let value = Float64(normalizedValue) * totalSeconds
        let seekTime = CMTime(seconds: value, preferredTimescale: 600)
        
        // 메인 플레이어가 재생 중이면 일단 일시정지
        if player?.timeControlStatus != .paused {
            player?.pause()
        }
        
        // (필요하다면) 썸네일 뷰의 위치 업데이트 처리
        
        // 현재 썸네일 seek가 진행 중이면 pendingThumbnailSeekTime 업데이트,
        // 아니면 바로 performThumbnailSeek 호출
        if isThumbnailSeekInProgress {
            pendingThumbnailSeekTime = seekTime
        } else {
            performThumbnailSeek(to: seekTime)
        }
    }
    
    // 실제 썸네일 seek를 수행하는 함수
    private func performThumbnailSeek(to seekTime: CMTime) {
        isThumbnailSeekInProgress = true
        let tolerance = CMTime(seconds: 0.1, preferredTimescale: 600)
        thumbnailPlayer?.seek(to: seekTime, toleranceBefore: tolerance, toleranceAfter: tolerance, completionHandler: { [weak self] finished in
            guard let self = self else { return }
            if finished {
                self.thumbnailPlayer?.playImmediately(atRate: 0) // 프레임 갱신
                self.thumbnailView.setNeedsLayout()
                self.thumbnailView.layoutIfNeeded()
                self.lastThumbnailSeekTime = self.thumbnailPlayer?.currentTime() ?? seekTime
                let actualTime = self.lastThumbnailSeekTime!.seconds
                let minutes = Int(actualTime / 60)
                let seconds = actualTime.truncatingRemainder(dividingBy: 60)
                print("썸네일 seek 완료, 시간: \(minutes)분 \(String(format: "%.3f", seconds))초")
            }
            self.isThumbnailSeekInProgress = false
            // pendingThumbnailSeekTime가 있으면 최신 요청을 수행
            if let pending = self.pendingThumbnailSeekTime, pending != self.lastThumbnailSeekTime {
                self.pendingThumbnailSeekTime = nil
                self.performThumbnailSeek(to: pending)
            }
        })
    }
    
    // 슬라이더 터치 업: 썸네일 뷰 숨기고 메인 플레이어 seek 요청
    @objc private func sliderTouchUp(_ sender: UISlider) {
        thumbnailView.isHidden = true
        guard let duration = player?.currentItem?.duration else { return }
        let totalSeconds = CMTimeGetSeconds(duration)
        
        // 최종 targetTime은 pendingThumbnailSeekTime 또는 마지막 seek 완료 시간을 사용
        var targetTime: CMTime
        if let pending = pendingThumbnailSeekTime {
            targetTime = pending
        } else if let last = lastThumbnailSeekTime {
            targetTime = last
        } else {
            targetTime = CMTime(seconds: Float64(sender.value) * totalSeconds, preferredTimescale: 600)
        }
        let tolerance = CMTime(seconds: 0.05, preferredTimescale: 600)
        
        player?.seek(to: targetTime, toleranceBefore: tolerance, toleranceAfter: tolerance, completionHandler: { [weak self] finished in
            guard let self = self else { return }
            self.player?.playImmediately(atRate: self.currentPlaybackRate)
            
            let newSliderValue = Float(targetTime.seconds / totalSeconds)
            DispatchQueue.main.async {
                self.seekSlider.setValue(newSliderValue, animated: true)
            }
            
            let minutes = Int(targetTime.seconds / 60)
            let seconds = targetTime.seconds.truncatingRemainder(dividingBy: 60)
            print("메인 플레이어 seek 완료, 시간: \(minutes)분 \(String(format: "%.3f", seconds))초")
        })
    }
    
    // 슬라이더 터치 다운: 썸네일 뷰 표시
    @objc private func sliderTouchDown(_ sender: UISlider) {
        isUserInteractingWithSlider = true
        thumbnailView.isHidden = false
    }
    
    private func addPeriodicTimeObserver() {
        guard let player = player else { return }
        let interval = CMTime(seconds: 1, preferredTimescale: 600)
        timeObserverToken = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let self = self,
                  let duration = self.player?.currentItem?.duration else { return }
            let totalSeconds = CMTimeGetSeconds(duration)
            if totalSeconds.isFinite && totalSeconds > 0 {
                let currentSeconds = CMTimeGetSeconds(time)
                self.seekSlider.value = Float(currentSeconds / totalSeconds)
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer?.frame = contentView.bounds
        thumbnailPlayerLayer?.frame = thumbnailView.bounds
    }
    
    // 자막 선택 UI: 액션 시트를 통해 사용자가 원하는 자막 트랙 선택
    @objc private func subtitleButtonTapped() {
        guard let playerItem = playerItem,
              let asset = playerItem.asset as? AVURLAsset,
              let legibleGroup = asset.mediaSelectionGroup(forMediaCharacteristic: .legible) else {
            print("자막 그룹을 찾을 수 없습니다.")
            return
        }
        
        let actionSheet = UIAlertController(title: "자막 선택", message: nil, preferredStyle: .actionSheet)
        
        // "자막 끄기" 옵션 추가 (nil 선택)
        let offAction = UIAlertAction(title: "자막 끄기", style: .default) { _ in
            self.playerItem?.select(nil, in: legibleGroup)
            print("자막 끄기 선택됨")
        }
        actionSheet.addAction(offAction)
        
        // availableSubtitleOptions에 저장된 각 옵션에 대해 액션 추가
        for option in availableSubtitleOptions {
            let action = UIAlertAction(title: option.displayName, style: .default) { _ in
                self.playerItem?.select(option, in: legibleGroup)
                print("자막 트랙 선택됨: \(option.displayName), locale: \(option.locale?.identifier ?? "none")")
            }
            actionSheet.addAction(action)
        }
        
        // 취소 액션
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        actionSheet.addAction(cancelAction)
        
        // UICollectionViewCell에서 직접 프레젠트하기 위해 상위 뷰 컨트롤러를 찾아서 사용
        if let vc = self.findViewController() {
            actionSheet.popoverPresentationController?.sourceView = self.contentView
            actionSheet.popoverPresentationController?.sourceRect = self.contentView.bounds
            vc.present(actionSheet, animated: true, completion: nil)
        }
    }
}

extension TestVideoCell: PallyConFPSLicenseDelegate {
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

// MARK: - AVPictureInPictureControllerDelegate
extension TestVideoCell: AVPictureInPictureControllerDelegate {
    
    @objc private func pipButtonTapped() {
        guard let pipController = pipController else {
            print("PIP 컨트롤러가 존재하지 않습니다.")
            return
        }
        if !pipController.isPictureInPictureActive {
            pipController.startPictureInPicture()
        } else {
            pipController.stopPictureInPicture()
        }
    }
    
    func pictureInPictureControllerWillStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        print("PIP 시작 예정")
    }
    
    func pictureInPictureControllerDidStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        print("PIP 시작됨")
    }
    
    func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, failedToStartPictureInPictureWithError error: Error) {
        print("PIP 시작 실패: \(error.localizedDescription)")
    }
    
    func pictureInPictureControllerWillStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        print("PIP 종료 예정")
    }
    
    func pictureInPictureControllerDidStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        print("PIP 종료됨")
    }
}

// MARK: - AVPlayerItemLegibleOutput Delegate
extension TestVideoCell: AVPlayerItemLegibleOutputPushDelegate {
    func legibleOutput(_ output: AVPlayerItemLegibleOutput,
                       didOutputAttributedStrings strings: [NSAttributedString],
                       nativeSampleBuffers nativeSamples: [Any],
                       forItemTime itemTime: CMTime) {
//        printX(strings.first)
    }
}

// MARK: - UIView Extension to Find ViewController
extension UIView {
    func findViewController() -> UIViewController? {
        if let nextResponder = self.next as? UIViewController {
            return nextResponder
        } else if let nextResponder = self.next as? UIView {
            return nextResponder.findViewController()
        } else {
            return nil
        }
    }
}
