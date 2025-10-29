//
//  SignUpAgreementListViewController.swift
//  LezhinSnack
//
//  Created by jinu0115 on 4/18/25.
//

import UIKit
import SnapKit
import Combine
import SwiftyUserDefaults

final class SignUpAgreementListViewController: UIViewController, ChildNavigationBarPresentable {
    
    private var headerCheckboxState: LZSnackCheckBox.CheckboxState = .unchecked
    
    private var subscriptions = Set<AnyCancellable>()
    
    enum Section {
        case main
    }

    private let viewModel: SignUpAgreementListViewModel
    
    init(viewModel: SignUpAgreementListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var agreementItems: [AgreementEntity] = []
    
    let childNavigationBar = ChildNavigationBar()
    private weak var headerView: SignUpAgreementListHeaderView?
    
    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.backgroundColor = UIColor(.backgroundDefault)
        return collectionView
    }()
    
    private var floatingActionButton: UIButton = {
        let floatingActionButton = UIButton(type: .system)
        floatingActionButton.setTitle("이용약관_다음버튼_타이틀".localized(), for: .normal)
        floatingActionButton.titleLabel?.font = .pretendardSemiBold(size: 16)
        floatingActionButton.backgroundColor = UIColor(.white)
        floatingActionButton.tintColor = UIColor(.foregroundInverse)
        floatingActionButton.layer.cornerRadius = 6
        
        return floatingActionButton
    }()
    
    private var dataSource: UICollectionViewDiffableDataSource<Section, AgreementEntity>!
    private var snapshot = NSDiffableDataSourceSnapshot<Section, AgreementEntity>()
    // 모달일 때 헤더 감추려면 false로 세팅
    var showsChildNavBar: Bool = false
    var onAgreementsAccepted: (([AgreementEntity]) -> Void)?
    
    let welcomeTitleView: UIView =  {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    let welcomeTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.pretendardMedium(size: 24)
        label.textColor = .white
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        label.isSkeletonable = true
        label.text = "환영합니다!"
        return label
    }()
    
    let welcomeTitleScriptLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.pretendardRegular(size: 13)
        label.textColor = UIColor(.whiteOpacity58)
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        label.isSkeletonable = true
        label.text = "시작 전 약관에 동의하고, 지금 바로 에피소드를 감상해보세요."
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        bind()
        fetchData()
    }
    
    
    func setupUI() {
        if showsChildNavBar {
            setupChildNavigationBar()
            childNavigationBar.delegate = self
            childNavigationBar.titleLabel.text = "앱바_이용약관_타이틀".localized
            welcomeTitleView.isHidden = true
        } else {
            welcomeTitleView.isHidden = false
            view.addSubview(welcomeTitleView)
            welcomeTitleView.snp.makeConstraints { make in
                make.leading.trailing.equalToSuperview().inset(16)
                make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(72)
                make.height.equalTo(56)
            }
            
            welcomeTitleView.addSubview(welcomeTitleLabel)
            welcomeTitleLabel.snp.makeConstraints { make in
                make.top.equalToSuperview().offset(0)
                make.leading.trailing.equalToSuperview().inset(0)
                make.height.equalTo(34)
            }
            welcomeTitleView.addSubview(welcomeTitleScriptLabel)
            welcomeTitleScriptLabel.snp.makeConstraints { make in
                make.top.equalTo(welcomeTitleLabel.snp.bottom).offset(0)
            }
            
            floatingActionButton.setTitle("동의하고 시작하기", for: .normal)
            floatingActionButton.backgroundColor = UIColor(.brandRed)
            floatingActionButton.tintColor = UIColor(.white)
        }
                
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        view.backgroundColor = .backgroundDefault
        
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview()
            if showsChildNavBar {
                make.top.equalTo(childNavigationBar.snp.bottom).offset(16)
            } else {
                make.top.equalTo(welcomeTitleView.snp.bottom).offset(32)
            }
        }
        
        collectionView.register(SignUpAgreementListCell.self)
        collectionView.register(SignUpAgreementListHeaderView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader)
        
        collectionView.allowsMultipleSelection = true
        collectionView.delegate = self
        
        configureDataSource()
        
        view.addSubview(floatingActionButton)
        floatingActionButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(56)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-8)
        }
        
        floatingActionButton.addTarget(self, action: #selector(nextButtonOnTapped), for: .touchUpInside)
    }
    
    private func bind() {
        viewModel.$agreementList
            .compactMap { $0 }
            .receive(on: RunLoop.main)
            .sink { [weak self] agreementList in
                self?.applySnapshot(items: agreementList)
            }
            .store(in: &subscriptions)
    }
    
    private func fetchData() {
        if showsChildNavBar {
            viewModel.fetchAgreementList()
        } else {
            viewModel.welcomefetchAgreementList()
        }
    }
    
    
    private func configureDataSource() {
        // Configure cell
        dataSource = UICollectionViewDiffableDataSource<Section, AgreementEntity>(
            collectionView: collectionView
        ) { [weak self] collectionView, indexPath, agreementItem in
            guard let self = self else { return UICollectionViewCell() }
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: SignUpAgreementListCell.reuseIdentifier, for: indexPath
            ) as? SignUpAgreementListCell else {
                return UICollectionViewCell()
            }

            // Configure cell
            cell.configure(with: agreementItem)
            cell.cellCheckBox.setState(agreementItem.isChecked ? .checked : .unchecked)
            cell.onDetailTap = { [weak self] in
                self?.openAgreementDetail(for: agreementItem)
                // cell의 인덱스로 리스트르 뷰컨트롤러에 주입시켜서 해당내용 추출
            }
            return cell
        }
        
        dataSource.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath in
            guard kind == UICollectionView.elementKindSectionHeader,
                let header = collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: SignUpAgreementListHeaderView.reuseIdentifier,
                    for: indexPath
                ) as? SignUpAgreementListHeaderView else { return UICollectionReusableView() }
            
            // [weak self] 캡처: 여기선 self가 약한 참조
            self?.headerView = header
            header.stateChanged = { [weak self] state in
                guard let self = self else { return }
                switch state {
                case .unchecked:
                    collectionView.deselectAll()
                case .checked:
                    collectionView.selectAll(using: self.dataSource)
                case .partial: break
                }
            }
            return header
        }
    }
    
    private func applySnapshot(items: [AgreementEntity]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, AgreementEntity>()
        snapshot.appendSections([.main])
        snapshot.appendItems(items)
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    private func createLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { [weak self] sectionIndex, layoutEnvironment in
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                  heightDimension: .estimated(58))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                   heightDimension: .estimated(58))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                           subitems: [item])
            
            let sectionLayout = NSCollectionLayoutSection(group: group)
            
            sectionLayout.contentInsets.top = 16
            
            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                    heightDimension: .absolute(58))
            let header = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerSize,
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top)
            
            sectionLayout.boundarySupplementaryItems = [header]
            return sectionLayout
        }
    }
    
    private func areRequiredAgreementsSelected() -> Bool {
        // 1) 전체 아이템 중 필수만 골라 ID 집합 만들기
        let allItems = dataSource.snapshot().itemIdentifiers
        let requiredIDs = Set(
            allItems
                .filter { $0.agreementType == .required }
                .map { $0.id }
        )
        // 2) 현재 선택된(체크된) 아이템 ID 집합 만들기
        let selectedIDs = Set(
            (collectionView.indexPathsForSelectedItems ?? [])
                .compactMap { dataSource.itemIdentifier(for: $0)?.id }
        )
        // 3) 필수 항목들이 전부 선택돼 있으면 true
        return requiredIDs.isSubset(of: selectedIDs)
    }

    // (임시) 제목 키워드로 마케팅 식별. 스키마 확정되면 key/enum으로 교체 권장.
    private func isMarketing(_ item: AgreementEntity) -> Bool {
        let t = item.title.lowercased()
        return t.contains("마케팅") || t.contains("프로모션") || t.contains("marketing") || t.contains("promotion")
    }
    
    @objc func nextButtonOnTapped() {
        
        guard areRequiredAgreementsSelected() else { return }
        
        guard let selectedIndexPaths = collectionView.indexPathsForSelectedItems else { return }
        let selectedItems = selectedIndexPaths.compactMap { dataSource.itemIdentifier(for: $0) }
        printX(selectedItems)

        // 마케팅 동의 저장 (선택 + optional + 마케팅)
        let agreeMarketing = selectedItems.contains { $0.agreementType == .optional && isMarketing($0) }
        Defaults.isAgreeMarketing = agreeMarketing
        
        if showsChildNavBar {
            onAgreementsAccepted?(selectedItems)
            let vc = SignUpSuccessViewController()
            navigationController?.pushHidesBottomBarViewController(vc, animated: true)
        } else {
            onAgreementsAccepted?(selectedItems)
            dismiss(animated: true)
        }
    }
    private func openAgreementDetail(for item: AgreementEntity) {
        // 제목 기반 라우팅 (스키마 확정 전 임시 매핑)
        let lower = item.title.lowercased()
        var title = item.title
        var urlString: String?
        
        if lower.contains("서비스 이용약관") || lower.contains("terms") || lower.contains("policy") {
            title = "서비스 이용약관"
            urlString = "https://dev.lezhinsnack.com/ko/agreement/policy"
        } else if lower.contains("개인정보") || lower.contains("privacy") {
            title = "개인정보 처리방침"
            urlString = "https://dev.lezhinsnack.com/ko/agreement/privacy" // 필요시 정확 URL로 교체
        }
        
        guard let s = urlString, let url = URL(string: s) else { return }
        let vc = AgreementDetailWebViewController(title: title, url: url)
        
        if let nav = self.navigationController {
            // 프로젝트에서 사용하던 확장 메서드 유지
            nav.pushHidesBottomBarViewController(vc, animated: true)
        } else {
            present(vc, animated: true) // 네비가 없을 때 대비
        }
    }

}

extension SignUpAgreementListViewController: UICollectionViewDelegate {
    @objc private func toggleAllCheckboxes(_ sender: LZSnackCheckBox) {
        let isChecked = sender.checkboxState == .checked
        isChecked ? collectionView.selectAll(using: dataSource) : collectionView.deselectAll()
    }
    
    // 셀 선택 처리
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        updateHeaderCheckbox()
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        updateHeaderCheckbox()
    }
    
    private func updateHeaderCheckbox() {
        let state = collectionView.selectionState(
            dataSource: dataSource,
            sectionID: .main, sectionIndex: 0
        )
        switch state {
        case .unchecked:
            headerView?.totalCheckBox.setState(.unchecked)
        case .partial:
            headerView?.totalCheckBox.setState(.partial)
        case .checked:
            headerView?.totalCheckBox.setState(.checked)
        }
    }
}


extension SignUpAgreementListViewController: ChildNavigationBarDelegate {
    func childNavigationBarDidTapBack(_ navigationBar: ChildNavigationBar) {
        navigationController?.popViewController(animated: true)
    }
}

extension SignUpAgreementListViewController: UIGestureRecognizerDelegate {
    
}
