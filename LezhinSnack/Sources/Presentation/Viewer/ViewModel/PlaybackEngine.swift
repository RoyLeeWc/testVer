//
//  PlaybackEngine.swift
//  LezhinSnack
//
//  Created by lwc on 9/19/25.
//
import Foundation
import SwiftSubtitles
import Alamofire
import Combine
import AVFoundation
import AVKit
import PallyConFPSSDK



struct PlaybackDescriptor: Hashable {
    let episodeId: String
    let assetKey: String
    let videoId: String
    let manifestURL: URL
    let drmToken: String? // nil이면 비DRM
    let cfCookieHeader: String?  
}

final class PlaybackEngine {
    // episodeId -> (contentId, asset)
    private var assets: [String: (assetKey: String, asset: AVURLAsset)] = [:]

    func prepare(_ desc: PlaybackDescriptor) {
        
        if assets[desc.episodeId] != nil { return }

        // DRM 준비: contentId 단위로 FairPlay에 등록 + asset 확보
        FairPlayStreamManager.shared.prepareDRM(
            videoId: desc.videoId,
            url: desc.manifestURL,
            token: desc.drmToken ?? "",
            contentId: desc.assetKey,
            cfCookieHeader: desc.cfCookieHeader ?? ""
        )

        if let asset = FairPlayStreamManager.shared.asset(for: desc.assetKey) {
            assets[desc.episodeId] = (desc.assetKey, asset)
        }
    }

    /// 화면에 뿌릴 때마다 "새로운" item 생성
    func item(for episodeId: String) -> AVPlayerItem? {
        guard let pair = assets[episodeId] else { return nil }
        return AVPlayerItem(asset: pair.asset)
    }

    /// 프리로딩 윈도우 유지, 나머지 정리
    func shrink(keeping ids: Set<String>) {
        let toDrop = assets.keys.filter { !ids.contains($0) }
        for k in toDrop {
            if let key = assets[k]?.assetKey {
                FairPlayStreamManager.shared.releaseAsset(forContentId: key)
            }
            assets.removeValue(forKey: k)
        }
    }
}
