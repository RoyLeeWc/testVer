//
//  DRMService.swift
//  LezhinSnack
//
//  Created by 신진우 on 4/28/25.
//
import PallyConFPSSDK
import AVFoundation

final class FairPlayStreamManager: NSObject, PallyConFPSLicenseDelegate, AVAssetResourceLoaderDelegate {
    static let shared = FairPlayStreamManager()

    lazy var fpsSDK: PallyConFPSSDK? = {
         return PallyConFPSSDK()
    }()
    
    private var drmConfigs = [String: PallyConDrmConfiguration]()  // contentId → DRM config

    private let certificateUrl = "https://license-global.pallycon.com/ri/fpsKeyManager.do?siteId=UVOO"
    
    private override init() {}

    // contentId ↔ AVURLAsset 만 저장
    private var drmAssets: [ String: AVURLAsset ] = [:]

    /// DRM 준비: AVURLAsset 에만 리소스 로더(delegate) 설정
    func prepareDRM(for contentId: String, url: URL, token: String) {
        // 1) AVURLAsset
        let asset = AVURLAsset(url: url)
        // 2) PallyConDRM 설정
        let config = PallyConDrmConfiguration(
            avURLAsset: asset,
            contentId: contentId,
            certificateUrl: certificateUrl,
            authData: token
        )
        config.delegate = self
        fpsSDK?.prepare(Content: config)
        // 3) 리소스 로더 위임 (optional)
//        asset.resourceLoader.setDelegate(self, queue: .main)

        drmAssets[contentId] = asset
    }

    /// AVPlayerItem 은 항상 새로 만들어서 반환
    func playerItem(for contentId: String) -> AVPlayerItem {
        guard let asset = drmAssets[contentId] else {
            fatalError("prepareDRM(for:url:token:) 먼저 호출해야 합니다.")
        }
        return AVPlayerItem(asset: asset)
    }

    // PallyConFPSLicenseDelegate
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
