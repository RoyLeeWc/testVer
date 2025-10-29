//
//  SearchViewController.swift
//  BalconyShortForm
//
//  Created by 신진우 on 3/9/25.
//

import UIKit
import SnapKit
import Combine
import Kingfisher
import TTGTags

final class SearchViewController: UIViewController {
    
    func didSelectTag(_ selectedIndex: Int) {
        
    }
    
    
    private var highlightKeyword: String?
    
    let viewModel: SearchViewModel
    
    var subscriptions = Set<AnyCancellable>()
    
    private let searchResultKind = "alternative-section-header"
    
    enum Section {
        case main
    }
    
    init?(viewModel: SearchViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private lazy var searchTextField: LZSnackSearchTextField = {
        let textField = LZSnackSearchTextField()
        textField.delegate = self
        textField.lzsSearchBarDelegate = self
        textField.returnKeyType = .search
        textField.addTarget(
            self,
            action: #selector(handleSearchTextChanged(_:)),
            for: .editingChanged
        )
        return textField
    }()
    
    private lazy var topBackButton: UIButton = {
        let button = UIButton(type: .custom)
        let image = UIImage(named: "ic_chevron_left_white")?
            .withRenderingMode(.alwaysOriginal)
        
        button.setImage(image, for: .normal)
        
        button.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        return button
    }()

    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .white
        return collectionView
    }()
    
    private lazy var noResultsLabel: UILabel = {
        let label = UILabel()
        label.text = "검색 결과가 없습니다."
        label.textColor = .white
        label.textAlignment = .center
        label.font = .pretendardRegular(size: 14)
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var emptyBackgroundView: UIView = {
        let view = UIView()
        view.addSubview(noResultsLabel)
        noResultsLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()        // 가로 중앙 정렬
            make.top.equalToSuperview().offset(24) // 상단에서 24pt 떨어진 위치
            make.leading.trailing.equalToSuperview().inset(20) // 좌우 여유
        }
        return view
    }()
    
    
    private var dataSource: UICollectionViewDiffableDataSource<Section, SearchContent>!
    
    private var searchTimer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        bind()
        
        collectionView.addPullToRefresh {
            
        }
        viewModel.loadRecentKeywords()
        viewModel.fetchInitialContent()
    }
    
    func setupUI() {
        
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        view.backgroundColor = UIColor(.backgroundDefault)
        
        setupSearchBar()
        setupCollectionView()
        configureDataSource()
        hideKeyboardWhenTappedAround()
        
    }
    
    func bind() {
        viewModel.$searchContentsResult
          .receive(on: RunLoop.main)
          .sink { [weak self] searchContents in
              // nil일 땐 빈 배열로
              let results = searchContents ?? []
              self?.applySnapshot(searchContents: results)
          }
          .store(in: &subscriptions)
        
        viewModel.$recentKeywords
          .receive(on: RunLoop.main)
          .sink { [weak self] recentKeywords in
              printX(recentKeywords)
              
              guard let header = self?.getHeaderView() else { return }
              header.configure(recent: recentKeywords)
          }
          .store(in: &subscriptions)
    }
    
    private func setupSearchBar() {
        view.addSubview(topBackButton)
        topBackButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.equalToSuperview().offset(12)
            make.height.width.equalTo(48)
        }
        
        view.addSubview(searchTextField)
        
        // SnapKit을 사용한 레이아웃 설정
        searchTextField.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.equalTo(topBackButton.snp.trailing)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(48)
        }
    }
    
    private func setupCollectionView() {

        view.addSubview(collectionView)
        
        
        collectionView.register(SearchedItemCell.self)
        collectionView.register(SearchHeaderView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader)
        
        collectionView.register(SearchResultHeaderView.self,
                                forSupplementaryViewOfKind: searchResultKind)
        
        collectionView.backgroundColor = UIColor(.backgroundDefault)
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(searchTextField.snp.bottom).offset(4)
            make.leading.equalTo(view.safeAreaLayoutGuide.snp.leading)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing)
        }
    }
    
    private func getHeaderView() -> SearchHeaderView? {
        return collectionView.supplementaryView(
            forElementKind: UICollectionView.elementKindSectionHeader,
            at: IndexPath(item: 0, section: 0)
        ) as? SearchHeaderView
    }
    
    private func getSearchResultHeaderView() -> SearchResultHeaderView? {
        return collectionView.supplementaryView(
            forElementKind: searchResultKind,
            at: IndexPath(item: 0, section: 0)
        ) as? SearchResultHeaderView
    }
    
    @objc private func backButtonTapped() {
        self.navigationController?.popViewController(animated: true)
    }
    
    // 컬렉션뷰 컴포지셔널 레이아웃 생성
    private func createLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { [weak self] sectionIndex, _ -> NSCollectionLayoutSection? in
            // 1) 아이템/그룹 정의 (기존 코드와 동일)
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                  heightDimension: .absolute(96))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                   heightDimension: .absolute(96))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                           subitem: item, count: 1)
            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = 10
            section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 0,
                                                            bottom: 16, trailing: 0)

            let isSearching = (self?.highlightKeyword != nil)

            let kind = isSearching
                ? "alternative-section-header"
                : UICollectionView.elementKindSectionHeader
            
            let headerHeightDimension: NSCollectionLayoutDimension = {
                if isSearching {
                    return .absolute(40)
                } else {
                    return .estimated(198)
                }
            }()

            let headerSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: headerHeightDimension
            )
            let header = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerSize,
                elementKind: kind,
                alignment: .top
            )
            section.boundarySupplementaryItems = [header]

            return section
        }
    }
    
    private func updateHeaderLayout() {
        // 텍스트 변경 후 레이아웃을 다시 세팅
        collectionView.setCollectionViewLayout(createLayout(), animated: false)
    }
    
    // 디파블 데이터소스 구성
    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, SearchContent>(collectionView: collectionView) { [weak self] collectionView, indexPath, searchResult -> UICollectionViewCell? in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchedItemCell.reuseIdentifier, for: indexPath) as? SearchedItemCell else { return UICollectionViewCell() }
            cell.configure(item: searchResult, keyword: self?.highlightKeyword)
            return cell
        }
        
        dataSource.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath in
            if kind == UICollectionView.elementKindSectionHeader {
                guard let headerView = collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: SearchHeaderView.reuseIdentifier,
                    for: indexPath) as? SearchHeaderView else {
                    return UICollectionReusableView()
                }
                headerView.delegate = self
                return headerView
            } else {
                guard let headerView = collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: SearchResultHeaderView.reuseIdentifier,
                    for: indexPath) as? SearchResultHeaderView else {
                    return UICollectionReusableView()
                }
                return headerView
            }
        }
    }
    
    private var lastSearchContents: [SearchContent] = []
    
    // 더미 데이터를 이용해 스냅샷 생성 및 데이터소스에 적용
    private func applySnapshot(searchContents: [SearchContent]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, SearchContent>()
        snapshot.appendSections([.main])
        snapshot.appendItems(searchContents, toSection: .main)

        dataSource.apply(snapshot, animatingDifferences: true) { [weak self] in
            guard let self = self else { return }
//            let topInset = self.collectionView.adjustedContentInset.top
//            self.collectionView.setContentOffset(
//                CGPoint(x: 0, y: -topInset),
//                animated: true
//            )
            
            self.getSearchResultHeaderView()?.setCount(searchContents.count)
            
            let visibleCells = self.collectionView.visibleCells.compactMap { $0 as? SearchedItemCell }
            visibleCells.forEach { cell in
                guard let indexPath = self.collectionView.indexPath(for: cell),
                      let item = self.dataSource.itemIdentifier(for: indexPath) else { return }

                cell.configure(item: item, keyword: self.highlightKeyword)
            }
        }
        
        if searchContents.isEmpty && highlightKeyword != nil {
            collectionView.backgroundView = emptyBackgroundView
        } else {
            collectionView.backgroundView = nil
        }
    }
    
}

extension SearchViewController: UITextFieldDelegate, LZSnackSearchTextFieldDelegate {
    
    func searchTextFieldDidClear(_ textField: LZSnackSearchTextField) {
        highlightKeyword = nil
        updateHeaderLayout()
        viewModel.fetchInitialContent()
    }
    
    
    @objc private func handleSearchTextChanged(_ textField: UITextField) {
        searchTimer?.invalidate()
        guard let keyword = textField.text, !keyword.isEmpty else { return }
        searchTimer = Timer.scheduledTimer(
            withTimeInterval: 1.0,
            repeats: false
        ) { [weak self] _ in
//            self?.viewModel.searchContent(keyword)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if let keyword = textField.text, !keyword.isEmpty {
            viewModel.searchContent(keyword)
            updateHeaderLayout()
            highlightKeyword = keyword
        }
        return true
    }
    
}


extension SearchViewController: SearchHeaderViewDelegate {
    
    func searchSelectedKeyword(_ searchHeaderView: SearchHeaderView, keyword: String) {
        viewModel.searchContent(keyword)
        highlightKeyword = keyword
    }
    
    func recentSearchDeleteAllTapped(_ searchHeaderView: SearchHeaderView) {
        viewModel.deleteAllRecentKeyword()
    }
    
    func recentSearchDeleteKeyword(_ searchHeaderView: SearchHeaderView, keyword: String) {
        viewModel.deleteRecentKeyword(keyword)
    }
    
}

extension SearchViewController: UIGestureRecognizerDelegate { }
