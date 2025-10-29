//
//  BalconyConstant.swift
//  BalconyShortForm
//
//  Created by 신진우 on 3/11/25.
//



final class LZSConstant {
    
    static let NavigationBarHeight = 56
    static let HomeNavigationBarHeight = 128
    static let TitleNavigationBarHeight = 56
    
    
    static let ResponseSuccess = "SUCCESS"
    static let ResponseError = "ERROR"
    static let NotRegisteredUser = "NOT_REGISTERED_USER"
    
}


struct LanguageCode {
    
    static let english  = "en"
    static let korean    = "ko"
    static let japanese    = "ja"
    static let simplifiedChinese = "zh-Hans"
}


enum InAppPurchaseType: CaseIterable {
    case monthly
    case annual
    case consumableCoin
    
    static var allCases: [InAppPurchaseType] {
        return [
            .monthly, .annual, .consumableCoin
        ]
    }
}

enum ViewerType {
    case mainViewer
    case promotionViewer
    case tastedViewer
}


enum TagType: CaseIterable {
    case lezhin
    case bomtoon
    case original
    case onlyTag
}


enum AllContentsSortOption: String, CaseIterable, LZSnackSortOption {
    case like  = "컨텍스트메뉴_좋아요순"
    case wish  = "컨텍스트메뉴_찜한순"
    case share = "컨텍스트메뉴_공유순"

    // 화면에 표시할 때 키를 localized 처리
    var displayName: String {
        rawValue.localized
    }
}

enum WatchHistorySortOption: String, CaseIterable, LZSnackSortOption {
    case recent = "컨텍스트메뉴_최신순"
    case old    = "컨텍스트메뉴_오래된순"

    var displayName: String {
        rawValue.localized
    }
}

enum MyCoinSortOption: String, CaseIterable, LZSnackSortOption {
    case total = "컨텍스트메뉴_전체순"
    case expired    = "컨텍스트메뉴_만료순"

    var displayName: String {
        rawValue.localized
    }
}


enum AgreementType {
    case required
    case optional
}
