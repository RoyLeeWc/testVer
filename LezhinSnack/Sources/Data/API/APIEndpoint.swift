//
//  APIEndpoint.swift
//  LezhinSnack
//
//  Created by jinu0115 on 6/2/25.
//


enum APIEndpoint: String {
    
    /// 게스트 모드 로그인
    case guestModeLogin     = "/api/balcony-api/auth/login"
    
//    /// SNS 로그인
//    case snsLogin     = "/api/balcony-api/auth/sign-in"
    
    ///검색
    case search = "/api/balcony-api/search/all"
    
    /// 충전내역
    case coinChargeHistory = "/api/balcony-api/payment/charge"
    
    /// 구매내역
    case purchaseHistory = "/api/balcony-api/purchase"
    
    /// iP 주소
    case ipAddress  = "https://api.ipify.org/?format=json"
    
    /// 유저 코인 조회
//    case userCoinBalance = "/api/balcony-api/coin/user"
    
    
//    case mainBanner = "/api/balcony-api/banner/list/MAIN"
   ///--------------------------
    /// 앱버전체크
    case appVersionsCheck = "/app/versions/check"
    
    /// 앱로그아웃
    case snackLogout = "/auth/logout"
    
    /// 진열 목록 조회
    case curationList = "/public/display/curation"
    
    /// 유저데이터 - 랭킹조회
    case contentsRanking = "/public/history/contents/ranking"
    
    /// 진열 배너 조회
    case contentsBanner = "/public/display/curation/banner"
    
    /// 연재중인 컨텐츠 조회
    case contentsOngoing = "/public/display/curation/contents/ongoing"
    
    /// 내가 시청중인 작품 조회
    case contentsLastWatch = "/public/my/contents/last-view/incomplete"
    
    /// 콘텐츠(작품) 설정 조회
    case curationContents = "/public/display/curation/contents"
    
    /// 토큰 리프레쉬
    case refreshAccessToken = "/public/auth/refresh"
    
    /// 유저 정보 조회 & 닉네임 수정
    case userInfo = "/user"
    
    /// 탈퇴 사유 조회
    case withdrawalReasons = "/public/user/withdrawal"
    
    /// 회원 탈퇴
    case withdrawal = "/user/withdrawal"
    
    /// 구독 정보 조회
    case mySubscriptions = "/my/subscriptions"
    
    /// 회원 코인 조회
    case myCoins       = "/my/coins"

    /// 회원 코인 충전 내역조회
    case myCoinCharges       = "/my/coins/charges"
        
    /// 회원 코인 사용 내역조회
    case coinUsageHistory    = "/history/coins/usage"
    
    /// 회원 결제 내역 조회
    case userPaymentHistory = "/history/users/payments"
    
    /// 최근 시청한 작품 조회
    case lastViewedContents = "/my/contents/last-view"
    
    /// 최근 시청한 작품 삭제 (대량)
    case lastViewedContentsDelete = "/my/contents/last-view/bulk-delete"
    
    /// 나의 찜한 작품 조회
    case favoriteContents = "/my/contents/favorite"
    
    /// 작품 찜 취소 (대량)
    case favoriteContentsDelete =  "/my/contents/favorites/bulk-delete"
    
    /// 구매 작품내역 조회
    case purchasedContents = "/my/contents/purchase"
    
    /// 구매 작품 숨기기 (대량)
    case purchasedContentsDelete =  "/my/contents/purchase/bulk-delete"
    
    /// 뷰어 - 맛보기 목록 조회
    case previewRecommendation = "/public/display/preview-recommendation"
    
    /// 공지사항 목록조회
    case noticeList = "/public/customer/notice"
    
    /// FAQ 카테고리 목록 조회
    case faqCategory = "/public/customer/faq/category"

    /// FAQ 목록 조회 & FAQ 조회
    case faqBase     = "/public/customer/faq"  // FAQ 조회 는 /{id} 붙여서 구성
    
    /// 결제 수단 조회
    case paymentProviders = "/payment/payment-providers"
    
    /// 코인 상품 조회
    case coinProducts = "/product/products"
    
    
    var baseURL: String {
        return AppContext.shared.baseApiUrl
    }
    /// new BaseURL
    var baseNewURL: String {
        if AuthProvider.IOS_GUEST == .IOS_GUEST {
            return AppContext.shared.baseNewApiUrl
        }else {
            return AppContext.shared.baseNewApiUrl
        }
    }
    
    /// 로그인
    static func authLogin(_ provider: AuthProvider) -> String {
        "\(AppContext.shared.baseNewApiUrl)/auth/login/\(provider.rawValue)"
    }
    
    /// 회원가입
    static func authJoin(_ provider: AuthProvider) -> String {
        "\(AppContext.shared.baseNewApiUrl)/public/user/join/ios/\(provider.rawValue)"
    }
    
    /// 게스트모드 회원가입
    static func guestModeJoin(_ provider: AuthProvider) -> String {
        "\(AppContext.shared.baseNewApiUrl)/public/user/join/\(provider.rawValue)"
    }
    
    /// 뷰어 - 컨텐츠 상세 조회
    static func displayContents(alias: String) -> String {
        "\(AppContext.shared.baseNewApiUrl)/public/display/contents/\(alias)"
    }
   
    /// 뷰어 - 컨텐츠 회차 조회
    static func displayEpisode(contentsAlias: String, episodeAlias: String) -> String {
        "\(AppContext.shared.baseNewApiUrl)/public/display/contents/\(contentsAlias)/\(episodeAlias)"
    }
    
    ///뷰어 - 비디오 정보 조회
    static func displayVideo(episodeId: String) -> String {
        "\(AppContext.shared.baseNewApiUrl)/public/display/video/\(episodeId)"
    }
    
    ///뷰어 - 회차정보 조회
    static func contentsEpisodes(contentsId: String) -> String {
        "\(AppContext.shared.baseNewApiUrl)/public/display/contents/\(contentsId)/episodes"
    }
    
    /// 작품 좋아요 등록/취소
    static func contentsLike(contentsId: String) -> String {
        "\(AppContext.shared.baseNewApiUrl)/my/contents/\(contentsId)/like"
    }
    
    /// 작품 찜 등록/취소
    static func contentsFavorite(contentsId: String) -> String {
        "\(AppContext.shared.baseNewApiUrl)/my/contents/\(contentsId)/favorite"
    }
    
    /// 시청이력 카운트 저장
    static func episodeViewCount(contentsId: String, episodeId: String) -> String {
        "\(AppContext.shared.baseNewApiUrl)/public/history/contents/\(contentsId)/episodes/\(episodeId)/views"
    }
    
    /// 특정 컨텐츠의 보유중인 에피소드 조회
    static func purchasedEpisodes(contentsId: String) -> String {
        "\(AppContext.shared.baseNewApiUrl)/my/contents/\(contentsId)/purchase"
    }
    
    /// 회원 결제 내역 상세 조회
    static func paymentDetail(transactionId: String) -> String {
        "\(AppContext.shared.baseNewApiUrl)/history/payments/\(transactionId)"
    }
    
    /// 공지사항 조회
    static func notice(noiceId: String) -> String {
        "\(AppContext.shared.baseNewApiUrl)/public/customer/notice/\(noiceId)"
    }
    
    var url: String {
        if self == .ipAddress {
            return self.rawValue
        } else if self == .guestModeLogin ||  self == .search || self == .coinChargeHistory || self == .purchaseHistory {
            return baseURL + self.rawValue
        } else {
            return baseNewURL + self.rawValue
        }
    }
}
