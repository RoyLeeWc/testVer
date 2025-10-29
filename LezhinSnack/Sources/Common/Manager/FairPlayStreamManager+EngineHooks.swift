//
//  FairPlayStreamManager+EngineHooks.swift
//  LezhinSnack
//
//  Created by 이우찬 on 9/20/25.
//
// FairPlayStreamManager+EngineHooks.swift
import AVFoundation

extension FairPlayStreamManager {
    /// 엔진에서 쓸 에셋 반환
    func asset(for contentId: String) -> AVURLAsset? {
        drmAssets[contentId]
    }

    /// (선택) 바로 새 item을 만들고 싶다면
    func makeFreshItem(for contentId: String) -> AVPlayerItem? {
        guard let a = drmAssets[contentId] else { return nil }
        return AVPlayerItem(asset: a)
    }

    /// 캐시 정리
    func releaseAsset(forContentId contentId: String) {
        drmAssets.removeValue(forKey: contentId)
        // fpsSDK에 별도 해제 API가 있으면 여기서 호출
    }
}

