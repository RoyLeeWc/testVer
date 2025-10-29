//
//  SignUpAgreementListViewController.swift
//  LezhinSnack
//
//  Created by jinu0115 on 4/18/25.
//

import UIKit
import SnapKit
import Combine


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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        bind()
        fetchData()
    }
    
    
    func setupUI() {
        setupChildNavigationBar()
        childNavigationBar.delegate = self
        childNavigationBar.titleLabel.text = "앱바_이용약관_타이틀".localized
                
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        view.backgroundColor = .backgroundDefault
        
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview()
            make.top.equalTo(childNavigationBar.snp.bottom).offset(16)
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
        viewModel.fetchAgreementList()
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
    
    @objc func nextButtonOnTapped() {
        guard let selectedIndexPaths = collectionView.indexPathsForSelectedItems else { return }
        let selectedItems = selectedIndexPaths.compactMap { dataSource.itemIdentifier(for: $0) }
        
        printX(selectedItems)
        
        let vc = SignUpSuccessViewController()
        navigationController?.pushHidesBottomBarViewController(vc, animated: true)
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
