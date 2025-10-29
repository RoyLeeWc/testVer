//
//  InAppPurchaseViewController.swift
//  BalconyShortForm
//
//  Created by jinu0115 on 3/12/25.
//


import UIKit
import SnapKit
import Combine
import SwiftyUserDefaults

enum PurchaseItem: Hashable {
    case coin(CoinProductEntity)
    case membership(MembershipProductEntity)
    case footer(ShopFooterEntity)
}

enum PurchaseSection: String, CaseIterable {
    case coin
    case membership
    case footer
}

protocol InAppPurchaseDismissNotifying: AnyObject {
    /// dismiss 되기 직전에 호출
    func willDismiss(_ viewController: UIViewController)
    /// dismiss 완료된 후 호출
    func didDismiss(_ viewController: UIViewController)
}

final class InAppPurchaseViewController: UIViewController, ChildNavigationBarPresentable {
    
    let childNavigationBar = ChildNavigationBar()
    
    weak var delegate: InAppPurchaseDismissNotifying?
    
    private var sections: [PurchaseSection] = PurchaseSection.allCases
    
    private var activeSections: [PurchaseSection] {
        var secs: [PurchaseSection] = [.coin]
        // 멤버십 데이터가 존재할 때만 섹션 추가
        if currentMemberships != nil {
            secs.append(.membership)
        }
        // Footer는 항상 보이도록
        secs.append(.footer)
        return secs
    }
    
    private var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<PurchaseSection, PurchaseItem>!
    
    private var subscriptions = Set<AnyCancellable>()
    
    
    private var currentCoins: [CoinProductEntity] = []
    private var currentMemberships: [MembershipProductEntity]? = nil
    
    let viewModel: InAppPurchaseViewModel
    var currentCoinBalance: String = "0"
    
    init?(viewModel: InAppPurchaseViewModel, currentCoinBalance: String) {
        self.viewModel = viewModel
        self.currentCoinBalance = currentCoinBalance
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad() 
        
        
        setupUI()
        bind()
        fetchData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.checkUnfinishedTransaction()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        delegate?.didDismiss(self)
    }
    
    private func bind() {
        viewModel.$coinProductList
            .receive(on: RunLoop.main)
            .sink { [weak self] coinProductList in
                // nil일 땐 빈 배열로
                self?.currentCoins = coinProductList ?? []
                self?.applySnapshot()
            }
            .store(in: &subscriptions)
        
        viewModel.$memberShipProductList
            .receive(on: RunLoop.main)
            .sink { [weak self] memberShipProductList in
                // nil일 땐 빈 배열로
                self?.currentMemberships = memberShipProductList    // nil 허용
                self?.applySnapshot()
            }
            .store(in: &subscriptions)
        
        viewModel.$purchaseViewState
            .receive(on: RunLoop.main)
            .sink { [weak self] purchaseViewState in
                guard let self = self else { return }
                
                switch purchaseViewState {
                case .idle: break
                case .loading:
                    LoadingManager.shared.show()
                case .success(let entity):
                    LoadingManager.shared.hide()
                    guard let vc = AppContext.container.resolve(PurchaseSuccessViewController.self, argument: entity) else { return }
                    self.navigationController?.pushHidesBottomBarViewController(vc)
                case .failure(_):
                    LoadingManager.shared.hide()
                    printX("결제실패")
                }
            }
            .store(in: &subscriptions)
    }
    
    private func setupUI() {
        setupChildNavigationBar()
        childNavigationBar.titleLabel.text = "앱바_충전소_타이틀".localized
        
        childNavigationBar.delegate = self
        
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        view.backgroundColor = UIColor(.backgroundDefault)
        
        setupCollectionView()
        configureDataSource()
        
        collectionView.addPullToRefresh { [weak self] in
            self?.fetchData()
        }
    }
    
    private func fetchData() {
        viewModel.fetchCoinProduct()
        viewModel.fetchMembershipProduct()
    }
    
    private func setupCollectionView() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.delegate = self
        
        collectionView.contentInsetAdjustmentBehavior = .never
        
        // 셀 및 헤더 등록
        collectionView.register(CoinProductCell.self)
        collectionView.register(CoinProductHeader.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader)
        
        
        collectionView.register(MembershipProductCell.self)
        collectionView.register(MembershipProductHeader.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader)
        
        collectionView.register(ShopFooterCell.self)

        view.addSubview(collectionView)
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(childNavigationBar.snp.bottom).offset(16)
            make.leading.equalTo(self.view.safeAreaLayoutGuide.snp.leading)
            make.trailing.equalTo(self.view.safeAreaLayoutGuide.snp.trailing)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
        }
        collectionView.isSkeletonable = true
        collectionView.backgroundColor = UIColor(.backgroundDefault)
    }
    
    private func createLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { [weak self] sectionIndex, layoutEnvironment in

            let section = self?.sections[sectionIndex]
            
            switch section {
            case .coin:
                return self?.makeCoinLayout()
            case .membership:
                return self?.makeMembershipLayout()
            case .footer:
                return self?.makeFooterLayout()
            case .none:
                return self?.makeCoinLayout()
            }
        }
    }
    
    private func makeCoinLayout() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5),
                                              heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .absolute(70))
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                       subitems: [item])
        
        group.interItemSpacing = .fixed(8)
        
        let sectionLayout = NSCollectionLayoutSection(group: group)
        sectionLayout.interGroupSpacing = 8
        sectionLayout.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 0, trailing: 16)
        
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                heightDimension: .absolute(56))
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top)
        
        header.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: -16, bottom: 0, trailing: -16)
        
        sectionLayout.boundarySupplementaryItems = [header]
        return sectionLayout
    }
    
    private func makeMembershipLayout() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .estimated(122))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .estimated(122))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                       subitems: [item])
        
        let sectionLayout = NSCollectionLayoutSection(group: group)
        sectionLayout.interGroupSpacing = 8
        sectionLayout.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 0, trailing: 16)
        
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                heightDimension: .absolute(66))
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top)
        
        header.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: -16, bottom: 0, trailing: -16)
        
        sectionLayout.boundarySupplementaryItems = [header]
        return sectionLayout
    }
    
    private func makeFooterLayout() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .estimated(122))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .estimated(122))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                       subitems: [item])
        
        let sectionLayout = NSCollectionLayoutSection(group: group)
        sectionLayout.interGroupSpacing = 8
        sectionLayout.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 0, trailing: 16)
        
        return sectionLayout
    }
    
    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<PurchaseSection, PurchaseItem>(collectionView: collectionView) { [weak self] collectionView, indexPath, item in
            switch item {
            case .coin(let coin):
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CoinProductCell.reuseIdentifier, for: indexPath) as? CoinProductCell else { return UICollectionViewCell()}
                cell.configure(with: coin)
                return cell
            case .membership(let member):
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MembershipProductCell.reuseIdentifier, for: indexPath) as? MembershipProductCell else { return UICollectionViewCell()}
                cell.configure(with: member)
                return cell
            case .footer(let info):
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ShopFooterCell.reuseIdentifier, for: indexPath) as? ShopFooterCell else { return UICollectionViewCell()}
                cell.configure(with: info)
                return cell
            }
        }
        
        dataSource.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath in
            let section = self?.sections[indexPath.section]

            switch section {
            case .coin:
                guard let headerView = collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: CoinProductHeader.reuseIdentifier,
                    for: indexPath) as? CoinProductHeader else {
                    return UICollectionReusableView()
                }
                
                headerView.delegate = self
                headerView.currentUserCoinView.setCoinText(self?.currentCoinBalance ?? "0")
                return headerView
            case .membership:
                guard let headerView = collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: MembershipProductHeader.reuseIdentifier,
                    for: indexPath) as? MembershipProductHeader else {
                    return UICollectionReusableView()
                }
                return headerView
            case .footer: return UICollectionReusableView()
            case .none: return UICollectionReusableView()
            }
        }
    }
    
    func applySnapshot() {
        // 1) 스냅샷 객체 생성
        var snapshot = NSDiffableDataSourceSnapshot<PurchaseSection, PurchaseItem>()

        // 2) 섹션 추가
        let sections: [PurchaseSection] = [.coin, .membership, .footer]
        snapshot.appendSections(sections)

        // 3) 코인 섹션에 들어갈 아이템 생성
        if !currentCoins.isEmpty {
            // currentCoins 배열을 PurchaseItem으로 매핑
            let coinItems: [PurchaseItem] = currentCoins.map { coinModel in
                .coin(coinModel)
            }
            snapshot.appendItems(coinItems, toSection: .coin)
        } else {
            // 빈 배열일 때도 섹션만 존재하도록 두고 싶다면,
            // 아래처럼 빈 배열을 추가하거나 생략해도 된다.
            snapshot.appendItems([], toSection: .coin)
        }

        // 4) 멤버십 섹션에 들어갈 아이템 생성
        if let memberships = currentMemberships, !memberships.isEmpty {
            // currentMemberships는 옵셔널로 허용했으므로, nil 체크
            let membershipItems: [PurchaseItem] = memberships.map { membershipModel in
                .membership(membershipModel)
            }
            snapshot.appendItems(membershipItems, toSection: .membership)
        } else {
            // 배열이 nil이거나 비어있다면 빈 배열을 추가
            snapshot.appendItems([], toSection: .membership)
        }
        
        let footerItems: [PurchaseItem] = viewModel.makeFooterText().map { membershipModel in
            .footer(membershipModel)
        }
        
        snapshot.appendItems(footerItems, toSection: .footer)
        
        // 5) 만들어진 스냅샷을 데이터 소스에 적용
        //    true로 주면 변경된 부분만 애니메이션으로 업데이트됨
        dataSource.apply(snapshot, animatingDifferences: false) { [weak self] in
            self?.collectionView?.refreshControl?.endRefreshing()
        }
    }
}


extension InAppPurchaseViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let sectionType = sections[indexPath.section]
        
        switch sectionType {
        case .coin:
            print("코인상품 선택")
            
            let mockPaymentInfo = PaymentInfoDTO(
                paymentId: "45",
                coinProductId: "265",
                episodeId: "0",
                purchaseType: nil,
                paymentMenu: "COIN_PRODUCT",
                redirectUrl: "https://dev.bomtoon.com/callback/payment",
                serviceId: "BOOMTOON_COM",
                accessToken: Defaults.accessToken,
                platform: "IOS_APP"
            )
            
            try? viewModel.purchaseConsumable(paymentInfo: mockPaymentInfo)
            
        case .membership:
            
            let entity = InAppPurchaseEntity(inAppPurchaseType: InAppPurchaseType.allCases.randomElement()!,
                                             amount: 4400,
                                             purchaseDate: LZSUtil.getCurrentTimeDate(),
                                             purchaseCoin: 300,
                                             purchasePeriod: LZSUtil.getCurrentTimeDate().toStringWithGMT(regionCode: LanguageCode.korean),
                                             paymentMethod: "충전소_결제수단_애플인앱".localized)
            
            guard let vc = AppContext.container.resolve(PurchaseSuccessViewController.self, argument: entity) else { return }
            self.navigationController?.pushHidesBottomBarViewController(vc)
        case .footer:
            break
        }
    }
}


extension InAppPurchaseViewController: LezhinCoinChargeDelegate {
    func didTapCoinChargeButton() {
        print("레진 코인 충전으로 이동")
    }
}



extension InAppPurchaseViewController: ChildNavigationBarDelegate {
    func childNavigationBarDidTapBack(_ navigationBar: ChildNavigationBar) {
        navigationController?.popViewController(animated: true)
    }
    
     
}

extension InAppPurchaseViewController: UIGestureRecognizerDelegate {
    
}
