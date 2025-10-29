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
    case twitter    = "twitter"
    case line       = "line"
    case apple      = "apple"
    case etc        = "etc"
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
    lazy var guestModeId        = self.xBalconyId
    
    
    
    /// API 베이스 URL
    var baseApiUrl  = "https://dev.bomtoon.com"
    
    /// Flex 서버 베이스 URL
    var flexApiUrl  = "https://dev-flex.bomtoon.com"
    
    var locale      = ""
    var xBalconyId  = "BOMTOON_COM"
    let xPlatform   = "IOS_APP"
    
    let supportLanguages = [
        LanguageCode.english,
        LanguageCode.korean,
        LanguageCode.japanese,
        LanguageCode.simplifiedChinese
    ]
    
    let isPrintAllApiLog = false
    
    let commonHeader: HTTPHeaders = {
        return [
            "Content-Type": "application/json",
            "x-balcony-id": "BOMTOON_COM",
            "x-platform": "IOS_APP"
        ]
    }()
    
//    let headerWithAccessToken: HTTPHeaders = {
//        var headers: HTTPHeaders = [
//            "Content-Type": "application/json",
//            "x-balcony-id": "BOMTOON_COM",
//            "x-platform": "IOS_APP"
//        ]
//        headers["Authorization"] = "Bearer \(Defaults.accessToken)"
//        return headers
//    }()
    
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
        injectViewController()
    }

    private func injectRepository() {
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
    }

    private func injectUseCase() {
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
        
    }

    private func injectViewModel() {
        
        // HomeViewModel 등록
        container.register(HomeViewModel.self) { resolver in
            let fetchHomeSectionsUseCase = resolver.resolveOrFail(FetchHomeSectionsUseCaseProtocol.self)
            return HomeViewModel(fetchHomeSectionsUseCase: fetchHomeSectionsUseCase)
        }
        
        // MyPageViewModel 등록
        container.register(MyPageViewModel.self) { resolver in
            let authUseCase = resolver.resolveOrFail(AuthUseCaseProtocol.self)
            let userUseCase = resolver.resolveOrFail(UserUseCaseProtocol.self)
            
            return MyPageViewModel(authUseCase: authUseCase, userUseCase: userUseCase)
        }

        // ChargeHistoryViewModel 등록
        container.register(ChargeHistoryViewModel.self) { resolver in
            let historyUseCase = resolver.resolveOrFail(HistoryUseCaseProtocol.self)
            let userUseCase = resolver.resolveOrFail(UserUseCaseProtocol.self)
            
            return ChargeHistoryViewModel(historyUserCase: historyUseCase, userUseCase: userUseCase)
        }
        
        // SplashViewModel 등록
        container.register(SplashViewModel.self) { resolver in
            let authUseCase = resolver.resolveOrFail(AuthUseCaseProtocol.self)
            return SplashViewModel(authUseCase: authUseCase)
        }
        
        // UserAuthViewModel 등록
        container.register(UserAuthViewModel.self) { resolver in
            let authUseCase = resolver.resolveOrFail(AuthUseCaseProtocol.self)
            return UserAuthViewModel(authUseCase: authUseCase)
        }
        
        // SearchViewModel 등록
        container.register(SearchViewModel.self) { resolver in
            let searchUseCase = resolver.resolveOrFail(SearchUseCaseProtocol.self)
            return SearchViewModel(searchUseCase: searchUseCase)
        }
        
        // InAppPurchaseViewModel 등록
        container.register(InAppPurchaseViewModel.self) { resolver in
            let inAppPurchaseUseCase = resolver.resolveOrFail(InAppPurchaseUseCaseProtocol.self)
            return InAppPurchaseViewModel(inAppPurchaseUseCase: inAppPurchaseUseCase)
        }
        
        // IAPBottomSheetViewModel 등록
        container.register(IAPBottomSheetViewModel.self) { resolver in
            let inAppPurchaseUseCase = resolver.resolveOrFail(InAppPurchaseUseCaseProtocol.self)
            return IAPBottomSheetViewModel(inAppPurchaseUseCase: inAppPurchaseUseCase)
        }
        
        // SettingViewModel 등록
        container.register(SettingViewModel.self) { resolver in
            return SettingViewModel()
        }
        
        // WithdrawViewModel 등록
        container.register(WithdrawViewModel.self) { resolver in
            let authUseCase = resolver.resolveOrFail(AuthUseCaseProtocol.self)
            return WithdrawViewModel(authUseCase: authUseCase)
        }
        
        // PurchasedContentListViewModel 등록
        container.register(PurchasedContentListViewModel.self) { resolver in
            let myListUseCase = resolver.resolveOrFail(MyListUseCaseProtocol.self)
            return PurchasedContentListViewModel(useCase: myListUseCase)
        }
        
        // WishListViewModel 등록
        container.register(WishListViewModel.self) { resolver in
            let myListUseCase = resolver.resolveOrFail(MyListUseCaseProtocol.self)
            return WishListViewModel(useCase: myListUseCase)
        }
        
        // WatchHistoryViewModel 등록
        container.register(WatchHistoryViewModel.self) { resolver in
            let myListUseCase = resolver.resolveOrFail(MyListUseCaseProtocol.self)
            return WatchHistoryViewModel(useCase: myListUseCase)
        }
        
        
        // EpisodeListViewModel 등록
        container.register(EpisodeListViewModel.self) { resolver in
            let episodeListUseCase = resolver.resolveOrFail(EpisodeListUseCaseProtocol.self)
            return EpisodeListViewModel(episodeListUseCase: episodeListUseCase)
        }
        
        // SignUpAgreementListViewModel 등록
        container.register(SignUpAgreementListViewModel.self) { resolver in
            let authUseCase = resolver.resolveOrFail(AuthUseCaseProtocol.self)
            return SignUpAgreementListViewModel(authUseCase: authUseCase)
        }
        
    }

    private func injectViewController() {
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
        
        // ViewerViewController 등록
        container.register(ViewerViewController.self) { (resolver: Resolver, viewerType: ViewerType) in
            let vc = ViewerViewController(viewerType: viewerType)
            return vc
        }
        
        // InAppPurchaseViewController 등록
        container.register(InAppPurchaseViewController.self) { (resolver: Resolver, currentCoinBalance: String) in
            let inAppPurchaseViewModel = resolver.resolveOrFail(InAppPurchaseViewModel.self)
            guard let viewController = InAppPurchaseViewController(viewModel: inAppPurchaseViewModel, currentCoinBalance: currentCoinBalance) else {
                fatalError("InAppPurchaseViewController 초기화 실패")
            }
            return viewController
        }
        
        container.register(IAPBottomSheetViewController.self) { (resolver: Resolver, currentCoinBalance: String) in
            let inAppPurchaseViewModel = resolver.resolveOrFail(IAPBottomSheetViewModel.self)
            guard let viewController = IAPBottomSheetViewController(viewModel: inAppPurchaseViewModel, currentCoinBalance: currentCoinBalance) else {
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
            let viewController = PaymentHistoryViewController()
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
    
    
    func requestPushNotificationPermissions() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("푸시 권한 요청 에러: \(error.localizedDescription)")
                return
            }
            
            if granted {
                // 메인 스레드에서 디바이스 토큰 등록 요청
                onMain {
                    UIApplication.shared.registerForRemoteNotifications()
                }
                
            } else {
                print("푸시 권한 요청 거부")
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
