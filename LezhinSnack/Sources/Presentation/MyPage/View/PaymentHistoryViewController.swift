//
//  PurchaseHistoryViewController.swift
//  LezhinSnack
//
//  Created by 신진우 on 5/22/25.
//

import UIKit


final class PaymentHistoryViewController: UIViewController, ChildNavigationBarPresentable {
    
    let childNavigationBar = ChildNavigationBar()
    
    enum Section {
        case history
    }
    
    private var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<Section, PaymentHistoryEntity>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .backgroundDefault
        setupChildNavigationBar()
        childNavigationBar.titleLabel.text = "결제 내역"
        childNavigationBar.delegate = self
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        configureCollectionView()
        configureDataSource()
        
        let randomPayments: [PaymentHistoryEntity] = (1...20).map { _ in
            let randomNum = Int.random(in: 1000..<10_000)
            return PaymentHistoryEntity(title: "Payment \(randomNum)")
        }
        
        applySnapshot(items: randomPayments)
    }
    
    
    private func configureCollectionView() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.allowsMultipleSelection = true
        
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
    
    func applySnapshot(items: [PaymentHistoryEntity] = []) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, PaymentHistoryEntity>()
        snapshot.appendSections([.history])
        snapshot.appendItems(items)
        dataSource.apply(snapshot, animatingDifferences: false) { [weak self] in
            
        }
    }
    
}

extension PaymentHistoryViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let cell = collectionView.cellForItem(at: indexPath) as? PaymentCell else { return }
        guard let titleText = cell.titleLabel.text else { return }
        
        if titleText.contains("구독") {
            onMain {
                let details: [(String,String)] = [
                    ("처리구분", "결제완료"),
                    ("결제일시", "2025.03.15 12:34:56 (GMT+9)"),
                    ("멤버십 구분", "월간 멤버십"),
                    ("결제금액", "39,000원"),
                    ("결제주기", "주간결제 (매주 화요일)"),
                    ("결제수단", "애플 앱스토어 인앱 결제")
                ]

                let popup = LZSnackPaymentPopup(
                    width: 320,
                    height: 256,
                    title: "결제처리 내역",
                    details: details,
                    productType: .subscription,
                    showsCloseButton: true
                )
                popup.show()
            }
        } else {
            onMain {
                let details: [(String,String)] = [
                    ("처리구분", "결제완료"),
                    ("결제일시", "2025.03.15 12:34:56 (GMT+9)"),
                    ("멤버십 구분", "월간 멤버십"),
                    ("결제금액", "39,000원"),
                    ("코인충전", "주간결제 (매주 화요일)"),
                    ("결제수단", "애플 앱스토어 인앱 결제")
                ]

                let popup = LZSnackPaymentPopup(
                    width: 320,
                    height: 256,
                    title: "결제처리 내역",
                    details: details,
                    productType: .coin,
                    showsCloseButton: true
                )
                popup.show()
            }
        }
    }
}

extension PaymentHistoryViewController: ChildNavigationBarDelegate {
    func childNavigationBarDidTapBack(_ navigationBar: ChildNavigationBar) {
        navigationController?.popViewController(animated: true)
    }
}

extension PaymentHistoryViewController: UIGestureRecognizerDelegate {
    
}
