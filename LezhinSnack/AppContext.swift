//
//  AppicationContext.swift
//  BalconyShortForm
//
//  Created by 신진우 on 3/8/25.
//

import UIKit
import Combine
import SwiftyUserDefaults
import Alamofire
import Swinject
import SwinjectStoryboard

enum AppLocale: String {
    case korea
    case china
    case japan
    case hongkong
}

enum SnsLoginType: String {
    case google     = "google"
    case facebook   = "facebook"
    case apple      = "apple"
    case lezhin     = "lezhin"
    case guestMode  = "apple_guest"
}


extension AppContext {
    static var container: Container {
        shared.container
    }
}

class AppContext {
    
    static let shared = AppContext()
    var subscriptions = Set<AnyCancellable>()
    let container = Container()
    
    private init() { }
    
    let deviceModelName         = UIDevice.current.name
    lazy var deviceUniqueID     = LZSUtil.retrieveUniqueDeviceIdentifier()
    lazy var deviceIPAddress    = Defaults.ipAddress
    
    lazy var guestModeId        = self.snackId
    
    
    
    /// API 베이스 URL
    var baseApiUrl  = "https://dev.bomtoon.com"
    
    var baseNewApiUrl  = "https://dev-api.lezhinsnack.com"
//    var basePublicNewApiUrl  = "https://dev-api.lezhinsnack.com/public"
    
    /// Flex 서버 베이스 URL
    var flexApiUrl  = "https://dev-flex.lezhinsnack.com"
    
    var locale      = ""
    var xBalconyId  = "BOMTOON_COM"
    
#if PROD
    var snackId  = "LEZHIN_SNACK"
#elseif DEV
    var snackId  = "LEZHIN_SNACK_DEV"
#endif
    
    
    
    let xPlatform   = "IOS_APP"
    
    let snackPlatform = "IOS"
    
    
    let supportLanguages = [
        LanguageCode.english,
        LanguageCode.korean,
        LanguageCode.japanese,
        LanguageCode.simplifiedChinese
    ]
    
    let isPrintAllApiLog = true
    
    let commonHeader: HTTPHeaders = {
        return [
            "Content-Type": "application/json",
            "x-balcony-id": "BOMTOON_COM",
            "x-platform": "IOS_APP"
        ]
    }()
    
    let postManTokenHeader: HTTPHeaders = {
        var headers: HTTPHeaders = [
            "SNACK-Language": "ko-KR",
            "SNACK-Platform": "IOS",
            "SNACK-Country": "KR",
            "SNACK-IP": Defaults.ipAddress,
            "SNACK-User-Id": "553"
        ]
        
        let postmanToken =  "eyJhbGciOiJIUzM4NCJ9.eyJ1c2VySWQiOiJuTmdIeTBTSlFLU0t3WHNlaFMrUlhrSklkMEtNM3l4QTB6c3FWMG02ejVVPSIsInNuc0lkIjoiU1Rtd25yaHlRbmZpSCtwSjJGZ1VSKzh5VVpoZE9JTU5CNDlQRDkrVFg4QT0iLCJqb2luVHlwZSI6IkVDQ1pEWnRDeC92V2MwMUs3YjhIdEVQQ25IU3F4cVhlOFR6TjVTUXZvNm89Iiwic3ViIjoiNTUzIiwiaWF0IjoxNzUyNjYwNjQ4LCJleHAiOjE3ODQxOTY2NDh9._l4XsiDHkmljIbNgW5JekVyQDHGa8ptG5n0CffUs2VFV-j28wJb80lxOJ8vH8nK3"
         headers["Authorization"] = "Bearer \(postmanToken)"
        
        return headers
    }()
    
    /// SNACK 기본 4종 + (옵션) User-Id + (옵션) Authorization Bearer
    func makeSnackAuthHeaders(includeUserId: Bool = true, includeBearer: Bool = true) -> HTTPHeaders {
        var headers = makeSnackHeaders(userIdHeader: includeUserId ? Defaults.userId : nil)
        if includeBearer, !Defaults.accessToken.isEmpty {
            let postmanToken = Defaults.accessToken
            headers["Authorization"] = "Bearer \(postmanToken)"
        }
        return headers
    }
    
    func makeSnackHeaders(userIdHeader: Int? = nil, token: String? = nil) -> HTTPHeaders {
            var headers: HTTPHeaders = [
                "SNACK-Language": "ko-KR",
                "SNACK-Platform": snackPlatform, // ex) "IOS"
                "SNACK-Country": "KR",
                "SNACK-IP": deviceIPAddress
            ]
            if let uid = userIdHeader{
                headers["SNACK-User-Id"] = "\(uid)"
            }
        if let accessToken = token, !accessToken.isEmpty {
            headers["Authorization"] = "Bearer \(accessToken)"
        }
            return headers
        }
    
    func makeFullSnackHeaders(userIdHeader: String? = nil, token: String? = nil) -> HTTPHeaders {
            var headers: HTTPHeaders = [
                "SNACK-Language": "ko-KR",
                "SNACK-Platform": snackPlatform, // ex) "IOS"
                "SNACK-Country": "KR",
                "SNACK-IP": deviceIPAddress,
                "SNACK-User-Id":"\(Defaults.userId)",
                "Authorization": "Bearer \(Defaults.accessToken)"
            ]
            return headers
        }
    
    func makeHeaderWithAccessToken() -> HTTPHeaders {
        var headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "x-balcony-id": "BOMTOON_COM",
            "x-platform": "IOS_APP"
        ]
        headers["Authorization"] = "Bearer \(Defaults.accessToken)"
        return headers
    }
    
    func restartApp() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return
        }
        
        // 기존의 rootViewController를 초기화하고, 새로운 AppCoordinator로 시작합니다.
        window.rootViewController = nil
        let newCoordinator = AppCoordinator(window: window)
        newCoordinator.isLoaded = true
        newCoordinator.start()
    }
    
    func importAllLocalizedStrings(completion: @escaping (Result<Void, Error>) -> Void) {
        // 처리할 언어 코드 배열
        let languages = supportLanguages
        let dispatchGroup = DispatchGroup()
        var errors: [Error] = []
        
//        if Defaults.isAlreadyImportLocalString {
//            completion(.success(()))
//            return
//        }
        
        for lang in languages {
            dispatchGroup.enter()
            let fileName = "localized_strings_\(lang)"
            
            guard let fileURL = Bundle.main.url(forResource: fileName, withExtension: "json") else {
                errors.append(LocalizedStringsError.invalidJsonString)
                dispatchGroup.leave()
                continue
            }
            
            do {
                let data = try Data(contentsOf: fileURL)
                guard let jsonString = String(data: data, encoding: .utf8) else {
                    errors.append(LocalizedStringsError.invalidJsonFormat)
                    dispatchGroup.leave()
                    continue
                }
                
                // 각 JSON 파일에 대해 Realm에 저장 처리
                LocalizedStringManager.shared.importLocalizedStrings(from: jsonString) { result in
                    switch result {
                    case .success:
                        break
                    case .failure(let error):
                        errors.append(error)
                    }
                    dispatchGroup.leave()
                }
            } catch {
                errors.append(error)
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            if errors.isEmpty {
                Defaults.isAlreadyImportLocalString = true
                completion(.success(()))
            } else {
                // 에러가 있다면 첫 번째 에러를 반환 (필요에 따라 에러들을 조합할 수 있음)
                completion(.failure(errors.first!))
            }
        }
    }
    
    
    func injectDependency() {
        
        Container.loggingFunction = {
            
            // Find the text that contains the missing registration.
            if let startOfMissingRegistration = $0.range(of: "Swinject: Resolution failed. Expected registration:\n\t")?.upperBound,
                let startOfAvailableOptions = $0.range(of: "\nAvailable registrations:")?.lowerBound {
                let missingRegistration = $0[startOfMissingRegistration ..< startOfAvailableOptions]

                // Ignore all reports for UIKit classes.
                if missingRegistration.contains("Storyboard: UI")
                    || missingRegistration.contains("Storyboard: MyApp.IgnoreThisViewController")
                    /* || other classes you want to ignore here */  {
                    return
                }

                // Print the missing registration.
                print("Swinject failed to find registration for \(missingRegistration)")
                return
            }

            // Some other message so just print it.
            print($0)
        }
        
        injectRepository()
        injectUseCase()
        injectViewModel()
        injectInteractor()
        injectViewController()
    }

    private func injectRepository() {
        
        // CustomerSupportRepository 등록
        container.register(CustomerSupportRepositoryProtocol.self) { _ in
            CustomerSupportRepository()
        }
        
        // SubscriptionRepository 등록
        container.register(SubscriptionRepositoryProtocol.self) { _ in
            SubscriptionRepository()
        }
        
        // ContentsRepository 등록
        container.register(ContentsRepositoryProtocol.self) { _ in
            ContentsRepository()
        }
        
        // AuthRepository 등록
        container.register(AuthRepositoryProtocol.self) { _ in
            AuthRepository()
        }
        
        // HomeSectionRepository 등록
        container.register(HomeSectionRepositoryProtocol.self) { _ in
            HomeSectionRepository()
        }
        
        // SearchRepository 등록
        container.register(SearchRepositoryProtocol.self) { _ in
            SearchRepository()
        }
        
        // HistoryRepository 등록
        container.register(HistoryRepositoryProtocol.self) { _ in
            HistoryRepository()
        }
        
        // InAppPurchaseRepository 등록
        container.register(InAppPurchaseRepositoryProtocol.self) { _ in
            InAppPurchaseRepository()
        }
        
        // UserRepository 등록
        container.register(UserRepositoryProtocol.self) { _ in
            UserRepository()
        }
        
        // MyListRepository 등록
        container.register(MyListRepositoryProtocol.self) { _ in
            MyListRepository()
        }
        
        // EpisodeListRepository 등록
        container.register(EpisodeListRepositoryProtocol.self) { _ in
            EpisodeListRepository()
        }
        
        // AppVersionRepository 등록
        container.register(AppVersionRepositoryProtocol.self) { _ in
            AppVersionRepository()
        }
        
        // CurationRepository 등록
        container.register(CurationRepositoryProtocol.self) { _ in
            CurationRepository()
        }
        
    }
    // swiftlint:disable function_body_length
    private func injectUseCase() {
        
        
        // ProductsUseCase 등록
        container.register(ProductsUseCaseProtocol.self) { resolver in
            let repo = resolver.resolveOrFail(InAppPurchaseRepositoryProtocol.self)
            return ProductsUseCase(repository: repo)
        }
        
        // IosTransactionUseCase 등록
        container.register(IosTransactionUseCaseProtocol.self) { resolver in
            let repo = resolver.resolveOrFail(InAppPurchaseRepositoryProtocol.self)
            return IosTransactionUseCase(repository: repo)
        }
        
        // IosTransactionUseCase 등록
        container.register(IosTransactionUseCaseProtocol.self) { resolver in
            let repo = resolver.resolveOrFail(InAppPurchaseRepositoryProtocol.self)
            return IosTransactionUseCase(repository: repo)
        }
        
        // PaymentProvidersUseCase 등록
        container.register(PaymentProvidersUseCaseProtocol.self) { resolver in
            let repo = resolver.resolveOrFail(InAppPurchaseRepositoryProtocol.self)
            return PaymentProvidersUseCase(repository: repo)
        }
        
        // AppPaymentReserveUseCase 등록
        container.register(AppPaymentReserveUseCaseProtocol.self) { resolver in
            let repo = resolver.resolveOrFail(InAppPurchaseRepositoryProtocol.self)
            return AppPaymentReserveUseCase(repository: repo)
        }
        
        // FAQUseCase 등록
        container.register(FAQUseCaseProtocol.self) { resolver in
            let contentsRepo = resolver.resolveOrFail(CustomerSupportRepositoryProtocol.self)
            return FAQUseCase(repository: contentsRepo)
        }
        
        // NoticesUseCase 등록
        container.register(NoticesUseCaseProtocol.self) { resolver in
            let contentsRepo = resolver.resolveOrFail(CustomerSupportRepositoryProtocol.self)
            return NoticesUseCase(repository: contentsRepo)
        }
        
        // DeletePurchasedViewedContentsUseCase 등록
        container.register(DeletePurchasedViewedContentsUseCaseProtocol.self) { resolver in
            let contentsRepo = resolver.resolveOrFail(MyListRepositoryProtocol.self)
            return DeletePurchasedViewedContentsUseCase(repository: contentsRepo)
        }
        
        // DeleteWishViewedContentsUseCase 등록
        container.register(DeleteWishViewedContentsUseCaseProtocol.self) { resolver in
            let contentsRepo = resolver.resolveOrFail(MyListRepositoryProtocol.self)
            return DeleteWishViewedContentsUseCase(repository: contentsRepo)
        }
        
        // DeleteLastViewedContentsUseCase 등록
        container.register(DeleteLastViewedContentsUseCaseProtocol.self) { resolver in
            let contentsRepo = resolver.resolveOrFail(MyListRepositoryProtocol.self)
            return DeleteLastViewedContentsUseCase(repository: contentsRepo)
        }
        
        // LastViewedContentsMyListUseCase 등록
        container.register(LastViewedMyListUseCaseProtocol.self) { resolver in
            let contentsRepo = resolver.resolveOrFail(MyListRepositoryProtocol.self)
            return LastViewedMyListUseCase(repository: contentsRepo)
        }

        // FavoriteContentsMyListUseCase 등록
        container.register(WishContentsMyListUseCaseProtocol.self) { resolver in
            let contentsRepo = resolver.resolveOrFail(MyListRepositoryProtocol.self)
            return WishContentsMyListUseCase(repository: contentsRepo)
        }
        // PurchasedContentsMyListUseCase 등록
        container.register(PurchasedContentsMyListUseCaseProtocol.self) { resolver in
            let contentsRepo = resolver.resolveOrFail(MyListRepositoryProtocol.self)
            return PurchasedContentsMyListUseCase(repository: contentsRepo)
        }
        
        // PaymentDetailUseCase 등록
        container.register(PaymentDetailUseCaseProtocol.self) { resolver in
            let contentsRepo = resolver.resolveOrFail(HistoryRepositoryProtocol.self)
            return PaymentDetailUseCase(repository: contentsRepo)
        }
        
        // PaymentHistoryUseCase 등록
        container.register(PaymentHistoryUseCaseProtocol.self) { resolver in
            let contentsRepo = resolver.resolveOrFail(HistoryRepositoryProtocol.self)
            return PaymentHistoryUseCase(repository: contentsRepo)
        }
        
        // CoinChargesUseCase 등록
        container.register(CoinChargesUseCaseProtocol.self) { resolver in
            let contentsRepo = resolver.resolveOrFail(HistoryRepositoryProtocol.self)
            return CoinChargesUseCase(repository: contentsRepo)
        }
        
        // CoinUsageHistoryUseCase 등록
        container.register(CoinUsageHistoryUseCaseProtocol.self) { resolver in
            let contentsRepo = resolver.resolveOrFail(HistoryRepositoryProtocol.self)
            return CoinUsageHistoryUseCase(repository: contentsRepo)
        }
        
        // MySubscriptionUseCase 등록
        container.register(MySubscriptionUseCaseProtocol.self) { resolver in
            let contentsRepo = resolver.resolveOrFail(SubscriptionRepositoryProtocol.self)
            return MySubscriptionUseCase(repository: contentsRepo)
        }
        
        // WithdrawUseCase 등록
        container.register(WithdrawUseCaseProtocol.self) { resolver in
            let contentsRepo = resolver.resolveOrFail(UserRepositoryProtocol.self)
            return WithdrawUseCase(repository: contentsRepo)
        }
        // WithdrawalReasonsUseCase 등록
        container.register(WithdrawalReasonsUseCaseProtocol.self) { resolver in
            let contentsRepo = resolver.resolveOrFail(UserRepositoryProtocol.self)
            return WithdrawalReasonsUseCase(repository: contentsRepo)
        }
        
        // UpdateNicknameUseCase 등록
        container.register(UpdateNicknameUseCaseProtocol.self) { resolver in
            let contentsRepo = resolver.resolveOrFail(UserRepositoryProtocol.self)
            return UpdateNicknameUseCase(repository: contentsRepo)
        }
        
        // UserInfoUseCase 등록
        container.register(UserInfoUseCaseProtocol.self) { resolver in
            let contentsRepo = resolver.resolveOrFail(UserRepositoryProtocol.self)
            return UserInfoUseCase(repository: contentsRepo)
        }
        
        // PurchasedEpisodesUseCase 등록
        container.register(PurchasedEpisodesUseCaseProtocol.self) { resolver in
            let contentsRepo = resolver.resolveOrFail(ContentsRepositoryProtocol.self)
            return PurchasedEpisodesUseCase(repository: contentsRepo)
        }
        
        // UnlikeContentsUseCase 등록
        container.register(TrackEpisodeViewUseCaseProtocol.self) { resolver in
            let contentsRepo = resolver.resolveOrFail(ContentsRepositoryProtocol.self)
            return TrackEpisodeViewUseCase(repository: contentsRepo)
        }
        
        // UnlikeContentsUseCase 등록
        container.register(UnfavoriteContentsUseCaseProtocol.self) { resolver in
            let contentsRepo = resolver.resolveOrFail(ContentsRepositoryProtocol.self)
            return UnfavoriteContentsUseCase(repository: contentsRepo)
        }
        
        // UnlikeContentsUseCase 등록
        container.register(FavoriteContentsUseCaseProtocol.self) { resolver in
            let contentsRepo = resolver.resolveOrFail(ContentsRepositoryProtocol.self)
            return FavoriteContentsUseCase(repository: contentsRepo)
        }
        
        // UnlikeContentsUseCase 등록
        container.register(UnlikeContentsUseCaseProtocol.self) { resolver in
            let contentsRepo = resolver.resolveOrFail(ContentsRepositoryProtocol.self)
            return UnlikeContentsUseCase(repository: contentsRepo)
        }
        
        // LikeContentsUseCase 등록
        container.register(LikeContentsUseCaseProtocol.self) { resolver in
            let contentsRepo = resolver.resolveOrFail(ContentsRepositoryProtocol.self)
            return LikeContentsUseCase(repository: contentsRepo)
        }
        
        // DisplayVideoUseCase 등록
        container.register(DisplayVideoUseCaseProtocol.self) { resolver in
            let contentsRepo = resolver.resolveOrFail(ContentsRepositoryProtocol.self)
            return DisplayVideoUseCase(repository: contentsRepo)
        }
        
        // FetchContentsDetailUseCase 등록
        container.register(FetchContentsDetailUseCaseProtocol.self) { resolver in
            let contentsRepo = resolver.resolveOrFail(ContentsRepositoryProtocol.self)
            return FetchContentsDetailUseCase(repo: contentsRepo)
        }
        
        // FetchEpisodeMetaUseCase 등록
        container.register(FetchEpisodeMetaUseCaseProtocol.self) { resolver in
            let contentsRepo = resolver.resolveOrFail(ContentsRepositoryProtocol.self)
            return FetchEpisodeMetaUseCase(repo: contentsRepo)
        }
        
        // FetchPreviewRecommendationsUseCase 등록
        container.register(FetchPreviewRecommendationsUseCaseProtocol.self) { resolver in
            let contentsRepo = resolver.resolveOrFail(ContentsRepositoryProtocol.self)
            return FetchPreviewRecommendationsUseCase(repo: contentsRepo)
        }
        
        // FetchContentsEpisodesUseCase 등록
        container.register(FetchContentsEpisodesUseCaseProtocol.self) { resolver in
            let contentsRepo = resolver.resolveOrFail(ContentsRepositoryProtocol.self)
            return FetchContentsEpisodesUseCase(repo: contentsRepo)
        }
        
        
        // AuthUseCase 등록
        container.register(AuthUseCaseProtocol.self) { resolver in
            let authRepository = resolver.resolveOrFail(AuthRepositoryProtocol.self)
            return AuthUseCase(authRepository: authRepository)
        }
        // FetchHomeSectionsUseCase 등록
        container.register(FetchHomeSectionsUseCaseProtocol.self) { resolver in
            let homeSectionRepository = resolver.resolveOrFail(HomeSectionRepositoryProtocol.self)
            return FetchHomeSectionsUseCase(homeSectionRepository: homeSectionRepository)
        }
        // SearchUseCase 등록
        container.register(SearchUseCaseProtocol.self) { resolver in
            let searchRepository = resolver.resolveOrFail(SearchRepositoryProtocol.self)
            return SearchUseCase(searchRepository: searchRepository)
        }
        // HistoryUseCase 등록
        container.register(HistoryUseCaseProtocol.self) { resolver in
            let historyRepository = resolver.resolveOrFail(HistoryRepositoryProtocol.self)
            return HistoryUseCase(historyRepository: historyRepository)
        }
        // InAppPurchaseUseCase 등록
        container.register(InAppPurchaseUseCaseProtocol.self) { resolver in
            let inAppPurchaseRepository = resolver.resolveOrFail(InAppPurchaseRepositoryProtocol.self)
            return InAppPurchaseUseCase(inAppPurchaseRepository: inAppPurchaseRepository)
        }
        
        // UserUseCase 등록
        container.register(UserUseCaseProtocol.self) { resolver in
            let userRepository = resolver.resolveOrFail(UserRepositoryProtocol.self)
            return UserUseCase(userRepositoryProtocol: userRepository)
        }
        
        // MyListUseCase 등록
        container.register(MyListUseCaseProtocol.self) { resolver in
            let myRepository = resolver.resolveOrFail(MyListRepositoryProtocol.self)
            return MyListUseCase(myListRepositoryProtocol: myRepository)
        }
        
        // EpisodeListUseCase 등록
        container.register(EpisodeListUseCaseProtocol.self) { resolver in
            let episodeListRepository = resolver.resolveOrFail(EpisodeListRepositoryProtocol.self)
            return EpisodeListUseCase(episodeListRepository: episodeListRepository)
        }
        
        // AppVersionUseCase 등록
        container.register(AppVersionUseCaseProtocol.self) { resolver in
            let repo = resolver.resolveOrFail(AppVersionRepositoryProtocol.self)
            return AppVersionUseCase(repo: repo)
        }
        
        // LoginUseCase 등록
        container.register(LoginUseCaseProtocol.self) { resolver in
            let repo = resolver.resolveOrFail(AuthRepositoryProtocol.self)
            return LoginUseCase(authRepository: repo)
        }

        // SignupUseCase 등록
        container.register(SignupUseCaseProtocol.self) { resolver in
            let repo = resolver.resolveOrFail(AuthRepositoryProtocol.self)
            return SignupUseCase(authRepository: repo)
        }
        // LogoutUseCase 등록
        container.register(LogoutUseCaseProtocol.self) { resolver in
            let repo = resolver.resolveOrFail(AuthRepositoryProtocol.self)
            return LogoutUseCase(authLogoutRepository: repo)
        }
        
        // CurationUseCase 등록
        container.register(CurationUseCaseProtocol.self) { resolver in
            let repo = resolver.resolveOrFail(CurationRepositoryProtocol.self)
            return CurationUseCase(curationRepository: repo)
        }
        
        // RankingUseCase 등록
        container.register(RankingUseCaseProtocol.self) { resolver in
            let repo = resolver.resolveOrFail(CurationRepositoryProtocol.self)
            return RankingUseCase(rankingrepository: repo)
        }
        
        // BannerUseCase 등록
        container.register(BannerUseCaseProtocol.self) { resolver in
            let repo = resolver.resolveOrFail(CurationRepositoryProtocol.self)
            return BannerUseCase(bannerrepository: repo)
        }
        
        // OngoingUseCase 등록
        container.register(OngoingUseCaseProtocol.self) { resolver in
            let repo = resolver.resolveOrFail(CurationRepositoryProtocol.self)
            return OngoingUseCase(ongoingRepository: repo)
        }
        
        // LastWatchUseCase 등록
        container.register(LastWatchUseCaseProtocol.self) { resolver in
            let repo = resolver.resolveOrFail(CurationRepositoryProtocol.self)
            return LastWatchUseCase(lastWatchRepository: repo)
        }
        
        // CurationContentsUseCase 등록
        container.register(CurationContentsUseCaseProtocol.self) { resolver in
            let repo = resolver.resolveOrFail(CurationRepositoryProtocol.self)
            return CurationContentsUseCase(curationRepository: repo)
        }
    }
    
    private func injectViewModel() {
        
        // CustomerSupportFAQListViewModel
        container.register(CustomerSupportFAQDetailViewModel.self) { (resolver: Resolver, faqId: Int) in
            let useCase = resolver.resolveOrFail(FAQUseCaseProtocol.self)
            return CustomerSupportFAQDetailViewModel(useCase: useCase, faqId: faqId)
        }
        
        // CustomerSupportFAQListViewModel 등록
        container.register(CustomerSupportFAQListViewModel.self) { (resolver, items: [FaqEntity]) in
//            let fqaUseCase = resolver.resolveOrFail(FAQUseCaseProtocol.self)
            return CustomerSupportFAQListViewModel(items: items)
        }
        
        // CustomerSupportViewModel 등록
        container.register(CustomerSupportViewModel.self) { resolver in
            let fqaUseCase = resolver.resolveOrFail(FAQUseCaseProtocol.self)
            return CustomerSupportViewModel(useCase: fqaUseCase)
        }
        
        // CustomerSupportNoticeListViewModel 등록
        container.register(CustomerSupportNoticeListViewModel.self) { resolver in
            let noticesUseCase = resolver.resolveOrFail(NoticesUseCaseProtocol.self)
            return CustomerSupportNoticeListViewModel(useCase: noticesUseCase)
        }
        
        // PaymentHistoryViewModel 등록
        container.register(PaymentHistoryViewModel.self) { resolver in
          
            let historyUseCase = resolver.resolveOrFail(PaymentHistoryUseCaseProtocol.self)
            let detailUseCase = resolver.resolveOrFail(PaymentDetailUseCaseProtocol.self)
            
            return PaymentHistoryViewModel(historyUseCase: historyUseCase, detailUseCase: detailUseCase)
        }
        
        container.register(ViewerViewModel.self) { resolver in
            let detailUseCase  = resolver.resolveOrFail(FetchContentsDetailUseCaseProtocol.self)
            let epsUseCase     = resolver.resolveOrFail(FetchContentsEpisodesUseCaseProtocol.self)
            let videoUseCase   = resolver.resolveOrFail(DisplayVideoUseCaseProtocol.self)
            let likeUseCase    = resolver.resolveOrFail(LikeContentsUseCaseProtocol.self)
            let unlikeUseCase  = resolver.resolveOrFail(UnlikeContentsUseCaseProtocol.self)
            let favoriteContentsUseCase = resolver.resolveOrFail(FavoriteContentsUseCaseProtocol.self)
            let unFavoriteContentsUseCase = resolver.resolveOrFail(UnfavoriteContentsUseCaseProtocol.self)
            let trackEpisodeViewUseCase = resolver.resolveOrFail(TrackEpisodeViewUseCaseProtocol.self)
            let purchasedEpisodesUseCase = resolver.resolveOrFail(PurchasedEpisodesUseCaseProtocol.self)
            let previewUseCase = resolver.resolveOrFail(FetchPreviewRecommendationsUseCaseProtocol.self)
            
            return ViewerViewModel(fetchContentsDetailUseCase: detailUseCase, fetchEpisodesUseCase: epsUseCase, displayVideoUseCase: videoUseCase, likeContentsUseCase: likeUseCase, unlikeContentsUseCase: unlikeUseCase,favoriteUseCase: favoriteContentsUseCase, unfavoriteUseCase: unFavoriteContentsUseCase, trackEpisodeViewUseCase: trackEpisodeViewUseCase, purchasedEpisodesUseCase: purchasedEpisodesUseCase, previewRecommendationsUseCase: previewUseCase)
        }
        
        // HomeViewModel 등록
        container.register(HomeViewModel.self) { resolver in
            
            let curationUseCase = resolver.resolveOrFail(CurationUseCaseProtocol.self)
            let rankingUseCase = resolver.resolveOrFail(RankingUseCaseProtocol.self)
            
            let bannerUseCase = resolver.resolveOrFail(BannerUseCaseProtocol.self)
            let ongoingUseCase = resolver.resolveOrFail(OngoingUseCaseProtocol.self)
            let lastWatchUseCase = resolver.resolveOrFail(LastWatchUseCaseProtocol.self)
            let curationContentsUseCase = resolver.resolveOrFail(CurationContentsUseCaseProtocol.self)
            
            return HomeViewModel(curationUseCase: curationUseCase,
                                 rankingUseCase: rankingUseCase,
                                 bannerUseCase: bannerUseCase,
                                 ongoingUseCase: ongoingUseCase,
                                 lastWatchUseCase: lastWatchUseCase,
                                 curationContentsUseCase: curationContentsUseCase
            )
        }
        
        // MyPageViewModel 등록
        container.register(MyPageViewModel.self) { resolver in
            let authUseCase = resolver.resolveOrFail(AuthUseCaseProtocol.self)
            let userUseCase = resolver.resolveOrFail(UserUseCaseProtocol.self)
            let logoutUseCase = resolver.resolveOrFail(LogoutUseCaseProtocol.self)
            let updateNicknameUseCase = resolver.resolveOrFail(UpdateNicknameUseCaseProtocol.self)
            let userInfoUseCase = resolver.resolveOrFail(UserInfoUseCaseProtocol.self)
            let loginUseCase = resolver.resolveOrFail(LoginUseCaseProtocol.self)
            let signupUseCase = resolver.resolveOrFail(SignupUseCaseProtocol.self)
            let mySubscriptionUseCase = resolver.resolveOrFail(MySubscriptionUseCaseProtocol.self)
            
            return MyPageViewModel(userUseCase: userUseCase,
                                   logoutUseCase: logoutUseCase,
                                   updateNicknameUseCase: updateNicknameUseCase,
                                   userInfoUseCase: userInfoUseCase,
                                   signupUseCase: signupUseCase,
                                   loginUseCase: loginUseCase,
                                   mySubscriptionUseCase: mySubscriptionUseCase)
        }

        // ChargeHistoryViewModel 등록
        container.register(ChargeHistoryViewModel.self) { resolver in
            let userUseCase = resolver.resolveOrFail(UserUseCaseProtocol.self)
            let coinChargesUseCase = resolver.resolveOrFail(CoinChargesUseCaseProtocol.self)
            let coinUsageHistoryUseCase = resolver.resolveOrFail(CoinUsageHistoryUseCaseProtocol.self)
            
            return ChargeHistoryViewModel(userUseCase: userUseCase,fetchCoinCharges: coinChargesUseCase,fetchCoinUsage: coinUsageHistoryUseCase)
        }
        
        // SplashViewModel 등록
        container.register(SplashViewModel.self) { resolver in
            
            let appVersionUseCase = resolver.resolveOrFail(AppVersionUseCaseProtocol.self)
            let loginUseCase = resolver.resolveOrFail(LoginUseCaseProtocol.self)
            let signupUseCase = resolver.resolveOrFail(SignupUseCaseProtocol.self)
            
            return SplashViewModel(appVersionUseCase: appVersionUseCase, loginUseCase: loginUseCase, signupUseCase: signupUseCase)
            
        }
        
        // UserAuthViewModel 등록
        container.register(UserAuthViewModel.self) { resolver in
            let login  = resolver.resolveOrFail(LoginUseCaseProtocol.self)
            let signup = resolver.resolveOrFail(SignupUseCaseProtocol.self)
            let logout = resolver.resolveOrFail(LogoutUseCaseProtocol.self)
            
            return UserAuthViewModel(loginUseCase: login, signupUseCase: signup, logoutUseCase: logout)
        }
        
        // SearchViewModel 등록
        container.register(SearchViewModel.self) { resolver in
            let searchUseCase = resolver.resolveOrFail(SearchUseCaseProtocol.self)
            return SearchViewModel(searchUseCase: searchUseCase)
        }
        
        // InAppPurchaseViewModel 등록
        container.register(InAppPurchaseViewModel.self) { resolver in
            let inAppPurchaseUseCase = resolver.resolveOrFail(InAppPurchaseUseCaseProtocol.self)
            let productsUseCaseUseCase = resolver.resolveOrFail(ProductsUseCaseProtocol.self)
            let paymentProvidersUseCaseUseCase = resolver.resolveOrFail(PaymentProvidersUseCaseProtocol.self)
            
            return InAppPurchaseViewModel(inAppPurchaseUseCase: inAppPurchaseUseCase, productsuseCase: productsUseCaseUseCase, paymentProvidersuseCase: paymentProvidersUseCaseUseCase)
        }
        
        // IAPBottomSheetViewModel 등록
        container.register(IAPBottomSheetViewModel.self) { resolver in
            let inAppPurchaseUseCase = resolver.resolveOrFail(InAppPurchaseUseCaseProtocol.self)
            let productsUseCaseUseCase = resolver.resolveOrFail(ProductsUseCaseProtocol.self)
            let paymentProvidersUseCaseUseCase = resolver.resolveOrFail(PaymentProvidersUseCaseProtocol.self)
            return IAPBottomSheetViewModel(inAppPurchaseUseCase: inAppPurchaseUseCase, productsuseCase: productsUseCaseUseCase, paymentProvidersuseCase: paymentProvidersUseCaseUseCase)
        }
        
        // SettingViewModel 등록
        container.register(SettingViewModel.self) { resolver in
            return SettingViewModel()
        }
        
        // WithdrawViewModel 등록
        container.register(WithdrawViewModel.self) { resolver in
            let authUseCase = resolver.resolveOrFail(AuthUseCaseProtocol.self)
            let withdrawalReasonsUseCase = resolver.resolveOrFail(WithdrawalReasonsUseCaseProtocol.self)
            let withdrawUseCase = resolver.resolveOrFail(WithdrawUseCaseProtocol.self)
            let mySubscriptionUseCase = resolver.resolveOrFail(MySubscriptionUseCaseProtocol.self)
            let loginUseCase = resolver.resolveOrFail(LoginUseCaseProtocol.self)
            let signupUseCase = resolver.resolveOrFail(SignupUseCaseProtocol.self)
            
            return WithdrawViewModel(withdrawalReasonsUseCase: withdrawalReasonsUseCase,
                                     withdrawUseCase: withdrawUseCase,
                                     mySubscriptionUseCase: mySubscriptionUseCase,
                                     signupUseCase: signupUseCase,
                                     loginUseCase: loginUseCase)
        }
        
        // PurchasedContentListViewModel 등록
        container.register(PurchasedContentListViewModel.self) { resolver in
            let myListUseCase = resolver.resolveOrFail(PurchasedContentsMyListUseCaseProtocol.self)
            let deleteUseCase = resolver.resolveOrFail(DeletePurchasedViewedContentsUseCaseProtocol.self)
            return PurchasedContentListViewModel(useCase: myListUseCase, deleteUseCase: deleteUseCase)
        }
        
        // WishListViewModel 등록
        container.register(WishListViewModel.self) { resolver in
            let myListUseCase = resolver.resolveOrFail(WishContentsMyListUseCaseProtocol.self)
            let deleteUseCase = resolver.resolveOrFail(DeleteWishViewedContentsUseCaseProtocol.self)
            return WishListViewModel(useCase: myListUseCase, deleteUseCase: deleteUseCase)
        }
        
        // WatchHistoryViewModel 등록
        container.register(WatchHistoryViewModel.self) { resolver in
            let myListUseCase = resolver.resolveOrFail(LastViewedMyListUseCaseProtocol.self)
            let deleteUseCase = resolver.resolveOrFail(DeleteLastViewedContentsUseCaseProtocol.self)
            return WatchHistoryViewModel(useCase: myListUseCase, deleteUseCase: deleteUseCase)
        }
        
        
        // EpisodeListViewModel 등록
        container.register(EpisodeListViewModel.self) { resolver in
            let episodeListUseCase = resolver.resolveOrFail(EpisodeListUseCaseProtocol.self)
            let episodeMetaUseCase = resolver.resolveOrFail(FetchEpisodeMetaUseCaseProtocol.self)
            
            return EpisodeListViewModel(episodeListUseCase: episodeListUseCase,episodeDetailsCase: episodeMetaUseCase)
        }
        
        // SignUpAgreementListViewModel 등록
        container.register(SignUpAgreementListViewModel.self) { resolver in
            let authUseCase = resolver.resolveOrFail(AuthUseCaseProtocol.self)
            return SignUpAgreementListViewModel(authUseCase: authUseCase)
        }
        
    }

    private func injectInteractor() {
        
        container.register(HomeViewerPrefetchInteractor.self) { resolver in
            let detail   = resolver.resolveOrFail(FetchContentsDetailUseCaseProtocol.self)
            let episodes = resolver.resolveOrFail(FetchContentsEpisodesUseCaseProtocol.self)
            return HomeViewerPrefetchInteractor(contentsDetailUseCases: detail, contentsEpisodesCases: episodes)
        }
        
    }
    
    private func injectViewController() {
        
        

        // injectViewController()
        container.register(CustomerSupportFAQDetailViewController.self) { (resolver: Resolver, faqId: Int) in
            
            guard let vm = resolver.resolve(CustomerSupportFAQDetailViewModel.self, argument: faqId) else {
                fatalError("CustomerSupportFAQDetailViewModel 초기화 실패")
            }
            
            guard let vc = CustomerSupportFAQDetailViewController(viewModel: vm) else {
                fatalError("CustomerSupportFAQDetailViewController 초기화 실패")
            }
            return vc
        }
        
        /// CustomerSupportFAQCategoryViewController 등록
        container.register(CustomerSupportFAQCategoryViewController.self) { (resolver, categories: [FaqCategoryEntity], faqs: [FaqEntity]) in
            guard let vc = CustomerSupportFAQCategoryViewController(categories: categories, faqs: faqs) else {
                fatalError("CustomerSupportFAQCategoryViewController 초기화 실패")
            }
            return vc
        }
        
        // CustomerSupportFAQListViewController 등록
        container.register(CustomerSupportFAQListViewController.self) { (resolver: Resolver, items: [FaqEntity], categoryName: String) in
            let vm = CustomerSupportFAQListViewModel(items: items)
//            let vm = resolver.resolveOrFail(CustomerSupportFAQListViewModel.self)
            guard let vc = CustomerSupportFAQListViewController(viewModel: vm, categoryName: categoryName) else {
                fatalError("CustomerSupportFAQListViewController 초기화 실패")
            }
            return vc
        }
        
        // CustomerSupportNoticeDetailViewController 등록
        container.register(CustomerSupportNoticeDetailViewController.self) { (resolver: Resolver, entity: NoticeEntity) in
            guard let viewController = CustomerSupportNoticeDetailViewController(entity: entity) else {
                fatalError("InAppPurchaseViewController 초기화 실패")
            }
            return viewController
        }
        
        // CustomerSupportNoticeListViewController 등록
        container.register(CustomerSupportNoticeListViewController.self) { resolver in
            let vm = resolver.resolveOrFail(CustomerSupportNoticeListViewModel.self)
            guard let viewController = CustomerSupportNoticeListViewController(viewModel: vm) else {
                fatalError("HomeViewController 초기화 실패")
            }
            return viewController
        }
        
        // CustomerSupportViewController 등록
        container.register(CustomerSupportViewController.self) { resolver in
            let vm = resolver.resolveOrFail(CustomerSupportViewModel.self)
            guard let viewController = CustomerSupportViewController(viewModel: vm) else {
                fatalError("HomeViewController 초기화 실패")
            }
            return viewController
        }
        
        // TermsListViewController 등록
        container.register(TermsListViewController.self) { resolver in
            let viewController = TermsListViewController()
            return viewController
        }
        
        // SplashViewController 등록
        container.register(SplashViewController.self) { resolver in
            let splashViewModel = resolver.resolveOrFail(SplashViewModel.self)
            guard let viewController = SplashViewController(viewModel: splashViewModel) else {
                fatalError("HomeViewController 초기화 실패")
            }
            return viewController
        }
        
        
        // HomeVieController 등록
        container.register(HomeViewController.self) { resolver in
            let homeViewModel = resolver.resolveOrFail(HomeViewModel.self)
            guard let viewController = HomeViewController(viewModel: homeViewModel) else {
                fatalError("HomeViewController 초기화 실패")
            }
            return viewController
        }
        
        // UserAuthViewController 등록
        container.register(UserAuthViewController.self) { resolver in
            let userAuthViewModel = resolver.resolveOrFail(UserAuthViewModel.self)
            guard let viewController = UserAuthViewController(viewModel: userAuthViewModel) else {
                fatalError("UserAuthViewController 초기화 실패")
            }
            return viewController
        }
        
        // MyPageViewController 등록
        container.register(MyPageViewController.self) { resolver in
            let myPageViewModel = resolver.resolveOrFail(MyPageViewModel.self)
            guard let viewController = MyPageViewController(viewModel: myPageViewModel) else {
                fatalError("MyPageViewController 초기화 실패")
            }
            return viewController
        }
        
        container.register(MyListTabViewController.self) { resolver in
            let viewController = MyListTabViewController()
            return viewController
        }
        
        // SearchViewController 등록
        container.register(SearchViewController.self) { resolver in
            let searchViewModel = resolver.resolveOrFail(SearchViewModel.self)
            guard let viewController = SearchViewController(viewModel: searchViewModel) else {
                fatalError("SearchViewController 초기화 실패")
            }
            return viewController
        }
        
        // 1) 기본: route 한 개 (이미 있던 것 유지)
        container.register(ViewerViewController.self) { (resolver: Resolver, route: ViewerRoute) in
            let vm = resolver.resolveOrFail(ViewerViewModel.self)
            return ViewerViewController(route: route, viewModel: vm)
        }

        // 2) 호환: (ViewerType, PlayInput) → route로 변환해 위 등록 재사용
        container.register(ViewerViewController.self) { (resolver: Resolver, type: ViewerType, input: PlayInput) in
            let route: ViewerRoute = .main(input)
            let vm = resolver.resolveOrFail(ViewerViewModel.self)
            return ViewerViewController(route: route, viewModel: vm)
        }

        // 3) 호환: (ViewerType, ViewerRoute) → route만 사용 (type은 무시 or 일치검사)
        container.register(ViewerViewController.self) { (resolver: Resolver, type: ViewerType, route: ViewerRoute) in
            // (선택) 일치 검사: type과 route.viewerType이 다르면 assert/log
            assert(type == route.viewerType, "ViewerType/ViewerRoute mismatch")
            let vm = resolver.resolveOrFail(ViewerViewModel.self)
            return ViewerViewController(route: route, viewModel: vm)
        }

        
        // 라우트 기반 등록: VC는 항상 VM을 생성자 주입으로 받는다
        container.register(ViewerViewController.self) { (resolver: Resolver, route: ViewerRoute) in
            let vm = resolver.resolveOrFail(ViewerViewModel.self)   // 기존 등록 그대로 사용
            return ViewerViewController(route: route, viewModel: vm)
        }
        
        
        // InAppPurchaseViewController 등록
        container.register(InAppPurchaseViewController.self) { (resolver: Resolver, currentCoinBalance: String) in
            let inAppPurchaseViewModel = resolver.resolveOrFail(InAppPurchaseViewModel.self)
            guard let viewController = InAppPurchaseViewController(viewModel: inAppPurchaseViewModel, currentCoinBalance: currentCoinBalance) else {
                fatalError("InAppPurchaseViewController 초기화 실패")
            }
            return viewController
        }
        
        container.register(IAPBottomSheetViewController.self) { (resolver: Resolver, requiredCoinBalance: String) in
            let inAppPurchaseViewModel = resolver.resolveOrFail(IAPBottomSheetViewModel.self)
            guard let viewController = IAPBottomSheetViewController(viewModel: inAppPurchaseViewModel, requiredCoinBalance: requiredCoinBalance) else {
                fatalError("InAppPurchaseViewController 초기화 실패")
            }
            return viewController
        }
        
        // PurchaseSuccessViewController 등록
        container.register(PurchaseSuccessViewController.self) { (resolver: Resolver, inAppPurchaseEntity: InAppPurchaseEntity) in
            let vc = PurchaseSuccessViewController(inAppPurchaseEntity: inAppPurchaseEntity)
            return vc
        }
        
        // ChangeLanguageViewController 등록
        container.register(ChangeLanguageViewController.self) { resolver in
            let viewController = ChangeLanguageViewController()
            return viewController
        }
        
        // MyCoinViewController 등록
        container.register(MyCoinViewController.self) { (resolver: Resolver, currentCoinBalance: String, expiringWindowDays: String) in
            
            let viewModel = resolver.resolveOrFail(ChargeHistoryViewModel.self)
            let viewController = MyCoinViewController(viewModel: viewModel, currentCoinBalance: currentCoinBalance, expiringWindowDays: expiringWindowDays)
            return viewController
        }

        // SettingViewController 등록
        container.register(SettingViewController.self) { resolver in
            let viewModel = resolver.resolveOrFail(SettingViewModel.self)
            guard let viewController = SettingViewController(viewModel: viewModel) else {
                fatalError("SettingViewController 초기화 실패")
            }
            return viewController
        }
        
        // WithdrawViewController 등록
        container.register(WithdrawViewController.self) { resolver in
            let viewModel = resolver.resolveOrFail(WithdrawViewModel.self)
            guard let viewController = WithdrawViewController(viewModel: viewModel) else {
                fatalError("SettingViewController 초기화 실패")
            }
            return viewController
        }
        
        // WithdrawResultViewController 등록
        container.register(WithdrawResultViewController.self) { resolver in
            let viewController = WithdrawResultViewController()
            return viewController
        }
        
        // PaymentHistoryViewController 등록
        container.register(PaymentHistoryViewController.self) { resolver in
            let viewModel = resolver.resolveOrFail(PaymentHistoryViewModel.self)
            let viewController = PaymentHistoryViewController(viewModel: viewModel)
            
            return viewController
        }
        
        // MembershipViewController 등록
        container.register(MembershipViewController.self) { resolver in
            let viewController = MembershipViewController()
            return viewController
        }

        // WatchHistoryListViewController 등록
        container.register(WatchHistoryListViewController.self) { resolver in
            let viewModel = resolver.resolveOrFail(WatchHistoryViewModel.self)
            let viewController = WatchHistoryListViewController(viewModel: viewModel)
            return viewController
        }
            
        // WishListViewController 등록
        container.register(WishListViewController.self) { resolver in
            let viewModel = resolver.resolveOrFail(WishListViewModel.self)
            let viewController = WishListViewController(viewModel: viewModel)
            return viewController
        }
        
        // PurchasedContentListViewController 등록
        container.register(PurchasedContentListViewController.self) { resolver in
            let viewModel = resolver.resolveOrFail(PurchasedContentListViewModel.self)
            let viewController = PurchasedContentListViewController(viewModel: viewModel)
            return viewController
        }
        
        // EpisodeListViewController 등록
        container.register(EpisodeListViewController.self) { resolver in
            let viewModel = resolver.resolveOrFail(EpisodeListViewModel.self)
            let viewController = EpisodeListViewController(viewModel: viewModel)
            return viewController
        }
        
        // SignUpAgreementListViewController 등록
        container.register(SignUpAgreementListViewController.self) { resolver in
            let viewModel = resolver.resolveOrFail(SignUpAgreementListViewModel.self)
            let viewController = SignUpAgreementListViewController(viewModel: viewModel)
            return viewController
        }
        
    }
    
    // swiftlint:enable function_body_length
    func requestPushNotificationPermissions() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("푸시 권한 요청 에러: \(error.localizedDescription)")
                return
            }
            
            if granted {
                Defaults.isAgreePushNotification = true
                // 메인 스레드에서 디바이스 토큰 등록 요청
                onMain {
                    UIApplication.shared.registerForRemoteNotifications()
                }
                
            } else {
                print("푸시 권한 요청 거부")
                Defaults.isAgreePushNotification = false
            }
        }
    }
    
    func getPushPermissionsState(completion: @escaping (Bool) -> Void) {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("푸시 권한 요청 에러: \(error.localizedDescription)")
                completion(false)
                return
            }
            
            if granted {
                onMain {
                    completion(true)
                }
            } else {
                print("푸시 권한 요청 거부")
                completion(false)
            }
        }
    }
    
    func makePushDict(info: [String: AnyObject]) -> [String: String] {
        let targetValue      = LZSUtil.extractValue(from: info, forKey: "target") ?? ""
        let subTargetValue   = LZSUtil.extractValue(from: info, forKey: "subTarget") ?? ""
        let paramsValue      = LZSUtil.extractValue(from: info, forKey: "params") ?? ""
        let pushIdValue      = LZSUtil.extractValue(from: info, forKey: "pushId") ?? ""
        
        return [
            "target": targetValue,
            "subTarget": subTargetValue,
            "params": paramsValue,
            "pushId": pushIdValue
        ]
    }
    
    func getAppVersion() -> String {
        guard let dictionary = Bundle.main.infoDictionary,
              let version = dictionary["CFBundleShortVersionString"] as? String else {return "1"}
        return version
    }
    
}
