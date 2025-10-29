//
//  ContentsRepository.swift
//  LezhinSnack
//
//  Created by lwc on 9/18/25.
//

import Foundation

protocol ContentsRepositoryProtocol {
    
    func fetchContentsDetail(alias: String) async throws -> DisplayContentsDetailEntity
    func fetchEpisodeMeta(contentsAlias: String, episodeAlias: String) async throws -> DisplayEpisodeEntity
    func fetchPreviewRecommendations() async throws -> PreviewRecommendationEntity
    func fetchDisplayVideo(episodeId: String,drmType: String,drmLicenseUserId: String) async throws -> DisplayVideoEntity
    func fetchContentsEpisodes(contentsId: String) async throws -> [ContentsEpisodeEntity]
    
    
    // 좋아요
    func like(contentsId: String) async throws
    // 좋아요 취소
    func unlike(contentsId: String) async throws
    // 찜등록
    func favorite(contentsId: String, episodeId: String) async throws
    // 찜등록 취소
    func unfavorite(contentsId: String) async throws
    // 에피소드 시청 카운트 저장 (재생시3초이상부터)
    func trackEpisodeView(contentsId: String,
                          episodeId: String,
                          subscriptionInfo: EpisodeViewCountAPIRequest.SubscriptionInfo?,
                          isViewCountOnly: Bool?) async throws
    // 특정 컨텐츠의 보유중인 에피소드 조회
    func fetchPurchasedEpisodes(contentsId: String) async throws -> [PurchasedEpisodeEntity]
}

enum ContentsRepositoryError: Error {
    case api(code: String, message: String)
}

final class ContentsRepository: ContentsRepositoryProtocol {

    func fetchContentsDetail(alias: String) async throws -> DisplayContentsDetailEntity {
        let req = DisplayContentsAPIRequest(contentsAlias: alias)
        let dto: DisplayContentsDTO = try await NetworkService.shared.requestAsync(req)
        
        guard dto.responseCode == APIResultType.success,
              let d = dto.data,
              let id = d.id,
              let alias = d.alias,
              let title = d.title
        else {
            let code = dto.errorData?.code ?? "UNKNOWN"
            let msg  = dto.errorData?.defaultMessage ?? "Fetch contents detail failed."
            throw ContentsRepositoryError.api(code: code, message: msg)
        }
        
        let creators: [DisplayContentsDetailEntity.Creator] = (d.creators ?? []).compactMap {
            guard let n = $0.realName, let id = $0.creatorId, let role = $0.creatorRoleType else { return nil }
            return .init(realName: n, creatorId: id, creatorRoleType: role)
        }
        
        func msToDate(_ ms: Int64?) -> Date? {
            guard let ms else { return nil }
            return Date(timeIntervalSince1970: TimeInterval(ms) / 1000.0)
        }
        
        // 공통 변환 헬퍼
        func mapTags(_ src: [TagDTO]?) -> [DisplayContentsDetailEntity.Tag] {
            (src ?? []).compactMap { t in
                guard let name = t.name, let id = t.tagId, let ord = t.orderNumber else { return nil }
                return .init(name: name, tagId: id, orderNumber: ord)
            }
        }
        
        
        return DisplayContentsDetailEntity(
            id: id,
            alias: alias,
            contact: d.contact,
            ageRatingType: d.ageRatingType,
            ageRatingReasons: d.ageRatingReasons ?? [],
            contractType: d.contractType,
            signatureBackgroundColor: d.signatureBackgroundColor,
            signatureImagePath: d.signatureImagePath,
            title: title,
            synopsis: d.synopsis,
            signatureText: d.signatureText,
            coverImagePath: d.coverImagePath,
            titleImagePath: d.titleImagePath,
            creators: creators,
            genreTags: mapTags(d.genreTags),
            keywordTags:mapTags(d.keywordTags),
            
            contentsOpenedAt: msToDate(d.contentsOpenedAt),
            contentsClosedAt: msToDate(d.contentsClosedAt),
            exposurePlatform: d.exposurePlatform ?? [],
            contentsIsShow: d.contentsIsShow ?? false,
            episodeCount: d.episodeCount ?? 0,
            isComplete: d.isComplete ?? false,
            isLiked: d.isLiked ?? false,
            likesCount: d.likesCount ?? 0,
            isFavorite: d.isFavorite ?? false,
            purchasedEpisodes: d.purchasedEpisodes.map(PurchasedEpisodeEntity.init),
            firstEpisodeAlias: d.firstEpisodeAlias
        )
    }
    
    
    
    func fetchEpisodeMeta(contentsAlias: String, episodeAlias: String) async throws -> DisplayEpisodeEntity {
        let req = DisplayEpisodeAPIRequest(contentsAlias: contentsAlias, episodeAlias: episodeAlias)
        let dto: DisplayEpisodeDTO = try await NetworkService.shared.requestAsync(req)
        
        guard dto.responseCode == APIResultType.success,
              let d = dto.data,
              let epId = d.episodeId,
              let epAlias = d.episodeAlias
        else {
            let code = dto.errorData?.code ?? "UNKNOWN"
            let msg  = dto.errorData?.defaultMessage ?? "Fetch episode meta failed."
            throw ContentsRepositoryError.api(code: code, message: msg)
        }
        
        func msToDate(_ ms: Int64?) -> Date? {
            guard let ms else { return nil }
            return Date(timeIntervalSince1970: TimeInterval(ms) / 1000.0)
        }
        
        return DisplayEpisodeEntity(
            episodeId: epId,
            episodeAlias: epAlias,
            episodeOpenedAt: msToDate(d.episodeOpenedAt),
            episodePreviewOpenedAt: msToDate(d.episodePreviewOpenedAt),
            possessionCoin: d.possessionCoin ?? 0,
            prevEpisodeAlias: d.prevEpisodeAlias,
            nextEpisodeAlias: d.nextEpisodeAlias
        )
    }
    
    func fetchPreviewRecommendations() async throws -> PreviewRecommendationEntity {
        let req = PreviewRecommendationAPIRequest()
        let dto: PreviewRecommendationDTO = try await NetworkService.shared.requestAsync(req)
        
        guard dto.responseCode == APIResultType.success else {
            let code = dto.errorData?.code ?? "UNKNOWN"
            let msg  = dto.errorData?.defaultMessage ?? "Fetch preview recommendation failed."
            throw ContentsRepositoryError.api(code: code, message: msg)
        }
        
        // 유효한 아이템만 필터링
        let items: [PreviewRecommendationItem] = dto.data.contents.compactMap { c in
            guard
                !c.contentsId.isEmpty,
                !c.contentsAlias.isEmpty,
                !c.episodeId.isEmpty,
                !c.titleImageUrl.isEmpty
            else { return nil }
            
            return PreviewRecommendationItem(
                contentsId: c.contentsId,
                contentsAlias: c.contentsAlias,
                episodeId: c.episodeId,
                titleImageUrl: c.titleImageUrl
            )
        }
        return PreviewRecommendationEntity(
            previewRecommendationId: dto.data.previewRecommendationId,
            items: items
        )
    }

    func fetchContentsEpisodes(contentsId: String) async throws -> [ContentsEpisodeEntity] {
        let req = ContentsEpisodesAPIRequest(contentsId: contentsId)
        let dto: ContentsEpisodesDTO = try await NetworkService.shared.requestAsync(req)
        
        guard dto.responseCode == APIResultType.success else {
            let code = dto.errorData?.code ?? "UNKNOWN"
            let msg  = dto.errorData?.defaultMessage ?? "Fetch episodes failed."
            throw ContentsRepositoryError.api(code: code, message: msg)
        }
        
        
        let list = (dto.data?.episodes ?? []).compactMap { e -> ContentsEpisodeEntity? in
            // 스키마 required 필드 보장
            guard
                let id = e.episodeId, !id.isEmpty,
                let typeStr = e.type, !typeStr.isEmpty,
                let alias = e.alias, !alias.isEmpty,
                let isFree = e.isFree,
                let isPreview = e.isPreview
            else { return nil }
            
            return ContentsEpisodeEntity(
                episodeId: id,
                type: EpisodeType(raw: typeStr),
                alias: alias,
                isFree: isFree,
                isPreview: isPreview,
                openedAt: e.openedAt,
                previewOpenedAt: e.previewOpenedAt
            )
        }
        //  서버가 SUCCESS지만 실데이터가 0개면 에러로 간주 (옵션)
        if list.isEmpty {
            throw ContentsRepositoryError.api(code: "EPISODE_NOT_FOUND", message: "에피소드를 찾을 수 없습니다.")
        }
        
        
        return list
    }
    
    func fetchDisplayVideo(episodeId: String,
                           drmType: String,
                           drmLicenseUserId: String) async throws -> DisplayVideoEntity {
        let req = DisplayVideoAPIRequest(
            episodeId: episodeId,
            drmType: drmType,
            drmLicenseUserId: drmLicenseUserId
        )
        
        //        let dto: DisplayVideoDTO = try await NetworkService.shared.requestAsync(req)
        
        // ⬇️ 응답 + HTTPURLResponse 동시 획득
        let (dto, httpRes, _) : (DisplayVideoDTO, HTTPURLResponse?, Data) = try await NetworkService.shared.requestAsyncWithResponse(req)

        // 공통 "SUCCESS"/"ERROR" 패턴 적용
        guard dto.responseCode == APIResultType.success,
              let d = dto.data,
              let videoId = d.videoId,
              let epId = d.episodeId,
              let contentsId = d.contentsId,
              let alias = d.alias,
              let manifestPath = d.manifestPath,
              let drmToken = d.drmToken
        else {
            // 서버가 알려준 에러 코드/메시지 전달
            let code = dto.errorData?.code ?? "UNKNOWN"
            let msg  = dto.errorData?.defaultMessage ?? "Display video fetch failed."
            // 프로젝트에서 이미 쓰는 에러 타입에 맞춰 던짐 (다른 Repo도 AuthRepositoryError.api 사용 중)
            throw ContentsRepositoryError.api(code: code, message: msg)
        }
        
        // ✅ 이 호출에서 내려준 Set-Cookie로 비디오 전용 Cookie 헤더 구성
        var cfHeader: String? = nil
        if let httpRes, let apiURL = URL(string: req.url) {
            cfHeader = CloudFrontCookieUtil.buildCookieHeader(from: httpRes, apiURL: apiURL)
        }
        

        return DisplayVideoEntity(
            videoId: videoId,
            episodeId: epId,
            contentsId: contentsId,
            alias: alias,
            manifestPath: manifestPath,
            drmToken: drmToken,
            cfCookieHeader: cfHeader
        )
    }
    
    func like(contentsId: String) async throws {
        let req = ContentsLikeAPIRequest(contentsId: contentsId)
        let dto: EmptyResponseDTO = try await NetworkService.shared.requestAsync(req)
        guard dto.responseCode == "SUCCESS" else {
            let code = dto.errorData?.code ?? "UNKNOWN"
            let msg  = dto.errorData?.defaultMessage ?? "Fetch contents detail failed."
            throw ContentsRepositoryError.api(code: code, message: msg)
        }
    }
    
    func unlike(contentsId: String) async throws {
        let req = ContentsUnlikeAPIRequest(contentsId: contentsId)
        let dto: EmptyResponseDTO = try await NetworkService.shared.requestAsync(req)
        guard dto.responseCode == "SUCCESS" else {
            let code = dto.errorData?.code ?? "UNKNOWN"
            let msg  = dto.errorData?.defaultMessage ?? "Unlike failed."
            throw ContentsRepositoryError.api(code: code, message: msg)
        }
    }
    
    func favorite(contentsId: String, episodeId: String) async throws {
        let req = ContentsFavoriteAPIRequest(contentsId: contentsId, episodeId: episodeId)
        let dto: EmptyResponseDTO = try await NetworkService.shared.requestAsync(req)
        guard dto.responseCode == APIResultType.success else {
            let code = dto.errorData?.code ?? "UNKNOWN"
            let msg  = dto.errorData?.defaultMessage ?? "Favorite failed."
            throw ContentsRepositoryError.api(code: code, message: msg)
        }
    }
    
    func unfavorite(contentsId: String) async throws {
        let req = ContentsUnfavoriteAPIRequest(contentsId: contentsId)
        let dto: EmptyResponseDTO = try await NetworkService.shared.requestAsync(req)
        guard dto.responseCode == APIResultType.success else {
            let code = dto.errorData?.code ?? "UNKNOWN"
            let msg  = dto.errorData?.defaultMessage ?? "Unfavorite failed."
            throw ContentsRepositoryError.api(code: code, message: msg)
        }
    }
    
    func trackEpisodeView(contentsId: String,
                          episodeId: String,
                          subscriptionInfo: EpisodeViewCountAPIRequest.SubscriptionInfo?,
                          isViewCountOnly: Bool?) async throws {
        let req = EpisodeViewCountAPIRequest(
            contentsId: contentsId,
            episodeId: episodeId,
            subscriptionInfo: subscriptionInfo,
            isViewCountOnly: isViewCountOnly
        )
        let dto: EmptyResponseDTO = try await NetworkService.shared.requestAsync(req)
        guard dto.responseCode == "SUCCESS" else {
            let code = dto.errorData?.code ?? "UNKNOWN"
            let msg  = dto.errorData?.defaultMessage ?? "Episode view count failed."
            throw ContentsRepositoryError.api(code: code, message: msg)
        }
    }
    
    func fetchPurchasedEpisodes(contentsId: String) async throws -> [PurchasedEpisodeEntity] {
        let req = PurchasedEpisodeAPIRequest(contentsId: contentsId)
        let dto: PurchasedContentsEpisodesDTO = try await NetworkService.shared.requestAsync(req)
        
        guard dto.responseCode == "SUCCESS" else {
            let code = dto.errorData?.code ?? "UNKNOWN"
            let msg  = dto.errorData?.defaultMessage ?? "Episode view count failed."
            throw ContentsRepositoryError.api(code: code, message: msg)
        }
        
        return dto.data.episodes.map(PurchasedEpisodeEntity.init)
    }
}
