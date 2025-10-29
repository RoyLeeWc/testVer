//
//  PurchaseHistoryViewController.swift
//  LezhinSnack
//
//  Created by 신진우 on 5/22/25.
//

import UIKit
import Combine

final class PaymentHistoryViewController: UIViewController, ChildNavigationBarPresentable {
    
    let childNavigationBar = ChildNavigationBar()
    
    enum Section {
        case history
    }
    
    private let emptyContentsLabel: UILabel = {
        let label = UILabel()
        label.font = .pretendardMedium(size: 14)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<Section, PaymentHistoryEntity>!
    // 주입
    private let viewModel: PaymentHistoryViewModel
    private var subscriptions = Set<AnyCancellable>()
    // 선택/상세용 인덱싱에 쓰기 좋게 로컬 캐시
    private var currentItems: [PaymentHistoryEntity] = []
    
    // 생성자 추가
    init(viewModel: PaymentHistoryViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        configureCollectionView()
        configureDataSource()
        bind()
        configureEmptyContentLabel()
        // 첫 로드 (0페이지부터)
        viewModel.reload()
    }
    
    private func setupUI() {
        view.backgroundColor = .backgroundDefault
        setupChildNavigationBar()
        childNavigationBar.titleLabel.text = "결제 내역"
        childNavigationBar.delegate = self
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    private func configureEmptyContentLabel() {
        emptyContentsLabel.text = "내목록_빈시청목록_타이틀".localized
        collectionView.backgroundView = emptyContentsLabel
    }
    
    private func updateEmptyState() {
        // let itemCount = dataSource.snapshot().itemIdentifiers(inSection: .history).count
        let itemCount = dataSource.snapshot().numberOfItems
        collectionView.isHidden = false
        collectionView.backgroundView?.isHidden = (itemCount != 0)
    }
    
    private func configureCollectionView() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.allowsMultipleSelection = false
        
        collectionView.backgroundColor = UIColor(.backgroundDefault)
        // 커스텀 셀 등록
        
        collectionView.register(PaymentCell.self)
        collectionView.delegate = self
        
        view.addSubview(collectionView)
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(childNavigationBar.snp.bottom).offset(16)
            make.leading.equalTo(view.safeAreaLayoutGuide.snp.leading)
            make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        
        collectionView.bounces = false
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .estimated(80))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .estimated(80))
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 1)
        
        let section = NSCollectionLayoutSection(group: group)
        
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    private func configureDataSource() {
        // Diffable Data Source 설정: 커스텀 셀 사용
        dataSource = UICollectionViewDiffableDataSource<Section, PaymentHistoryEntity>(collectionView: collectionView) { [weak self] collectionView, indexPath, item -> UICollectionViewCell? in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PaymentCell.reuseIdentifier, for: indexPath) as? PaymentCell else { return nil }
            
            cell.configure(item)
            
            return cell
        }
    }
    
    private func bind() {
        // 리스트 바인딩
        viewModel.$payments
            .receive(on: RunLoop.main)
            .sink { [weak self] items in
                guard let self else { return }
                self.currentItems = items
                self.collectionView.refreshControl?.endRefreshing()
                self.applySnapshot(items: items)
            }
            .store(in: &subscriptions)
        
        // 상세 바인딩
        viewModel.$paymentDetail
            .receive(on: RunLoop.main)
            .sink { detail in
                guard let detail else { return }
                // TODO: 여기서 detail을 팝업/상세뷰에 넘겨서 사용
                
                let details = self.buildDetails(from: detail)
                let productType = self.popupProductType(for: detail)
                
                let popup = LZSnackPaymentPopup(
                    width: 320,
                    height: 256,
                    title: "결제처리 내역",
                    details: details,
                    productType: productType,
                    showsCloseButton: true
                )
                popup.show()
                
                
                print("Payment Detail fetched: \(detail.tradeId) \(detail.status) \(detail.amount) \(detail.currencyType)")
            }
            .store(in: &subscriptions)
    }
    
    func applySnapshot(items: [PaymentHistoryEntity] = []) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, PaymentHistoryEntity>()
        snapshot.appendSections([.history])
        snapshot.appendItems(items)
        dataSource.apply(snapshot, animatingDifferences: false) { [weak self] in
            self?.updateEmptyState()
        }
    }
    
}

extension PaymentHistoryViewController: UICollectionViewDelegate {
    // 무한 스크롤 트리거
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        viewModel.loadNextIfNeeded(visibleIndex: indexPath.item)
    }
    
    // 셀 탭 → 상세 호출
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.item < currentItems.count else { return }
        let model = currentItems[indexPath.item]
        viewModel.fetchPaymentDetail(tradeId: model.tradeId)
    }
    
}

extension PaymentHistoryViewController: ChildNavigationBarDelegate {
    func childNavigationBarDidTapBack(_ navigationBar: ChildNavigationBar) {
        navigationController?.popViewController(animated: true)
    }
}

extension PaymentHistoryViewController: UIGestureRecognizerDelegate {
    
}

// MARK: - Detail → UI 매핑/포맷터
private extension PaymentHistoryViewController {

    func buildDetails(from paymentDetail: PaymentDetailEntity) -> [(String,String)] {
        var rows: [(String,String)] = []

        rows.append(("처리구분", displayStatusText(paymentDetail.status)))
        rows.append(("결제일시", formatDateKST(ms: paymentDetail.createdAt)))
        
        switch paymentDetail.paymentMenuType {
        case .subscriptionProduct:
            rows.append(("멤버십 구분", displayMembershipText(paymentDetail.periodType)))
            rows.append(("결제금액", formatAmountOnly(paymentDetail.amount)))
            rows.append(("결제주기", displayPeriodText(paymentDetail.periodType)))
        case .coinProduct:
            rows.append(("결제 구분", "코인 충전"))
            rows.append(("결제금액", formatAmountOnly(paymentDetail.amount) + "원"))
            rows.append(("코인충전", formatAmountOnly(paymentDetail.coin ?? 0)))
        case .coinConversion:
            rows.append(("결제 구분", "코인 충전"))
            rows.append(("결제금액", formatAmountOnly(paymentDetail.amount) + "원"))
            rows.append(("코인충전", formatAmountOnly(paymentDetail.coin ?? 0)))
        case .unknown:
            break
        }
        rows.append(("결제수단", displayProviderText(paymentDetail.paymentProviderType)))
        return rows
    }

    func formatAmountOnly(_ amount: Int) -> String {
        let nf = NumberFormatter()
        nf.numberStyle = .decimal
        nf.locale = Locale(identifier: "ko_KR")
        return nf.string(from: amount as NSNumber) ?? "\(amount)"
    }
    
    func popupProductType(for paymentDetail: PaymentDetailEntity) -> ProductType {
        switch paymentDetail.paymentMenuType {
        case .subscriptionProduct: return .subscription
        case .coinProduct:         return .coin
        case .coinConversion:      return .coin
        case .unknown:             return .coin
        }
    }

    func displayProviderText(_ type: PaymentProviderType) -> String {
        switch type {
        case .iosApp:   return "애플 앱스토어 인앱 결제"
        case .andPlay:  return "구글 플레이 스토어 인앱 결제"
        case .unknown:  return "기타"
        }
    }

    func displayStatusText(_ status: PaymentStatus) -> String {
        switch status {
        case .complete: return "결제완료"
        case .fail:     return "결제실패"
        case .cancel:   return "결제취소"
        case .cancelPg: return "PG사 취소"
        case .unknown:  return "알 수 없음"
        }
    }

    func displayMembershipText(_ period: PeriodType?) -> String {
        switch period ?? .unknown {
        case .monthly:          return "월간 멤버십"
        case .annual:           return "연간 멤버십"
        case .oneTimePurchase:  return "일시 결제"
        case .unknown:          return "-"
        }
    }

    func displayPeriodText(_ period: PeriodType?) -> String {
        switch period ?? .unknown {
        case .monthly:          return "월간"
        case .annual:           return "연간"
        case .oneTimePurchase:  return "1회 결제"
        case .unknown:          return "-"
        }
    }

    func formatDateKST(ms: Int64?) -> String {
        guard let ms else { return "-" }
        let date = Date(timeIntervalSince1970: TimeInterval(ms) / 1000.0)

        let df = DateFormatter()
        df.locale = Locale(identifier: "ko_KR")
        df.timeZone = TimeZone(identifier: "Asia/Seoul")
        df.dateFormat = "yyyy.MM.dd HH:mm:ss"

        // GMT 오프셋 표기
        let seconds = TimeZone(identifier: "Asia/Seoul")?.secondsFromGMT(for: date) ?? 0
        let hours = seconds / 3600
        let sign = hours >= 0 ? "+" : "-"
        let gmt = String(format: " (GMT%@%d)", sign, abs(hours))

        return df.string(from: date) + gmt
    }
}
