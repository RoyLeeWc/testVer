//
//  TermsListViewController.swift
//  LezhinSnack
//
//  Created by lwc on 9/30/25.
//

import UIKit
import SnapKit

struct TermsItem: Hashable {
    let id = UUID()
    let title: String
    let urlString: String
}



final class TermsListViewController: UIViewController, ChildNavigationBarPresentable {

    enum Section { case main }

    let childNavigationBar = ChildNavigationBar()

    private var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<Section, TermsItem>!

    
    private let items: [TermsItem] = [
        .init(title: "서비스 이용약관",
              urlString: "https://dev.lezhinsnack.com/ko/agreement/policy"),
        .init(title: "개인정보 처리방침",
              urlString: "https://dev.lezhinsnack.com/ko/agreement/policy")
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(.backgroundDefault)
        setupNav()
        setupCollectionView()
        applySnapshot()
    }

    private func setupNav() {
        setupChildNavigationBar()
        childNavigationBar.delegate = self
        childNavigationBar.titleLabel.text = "앱바_이용약관_타이틀".localized
        navigationController?.interactivePopGestureRecognizer?.delegate = self
    }

    private func setupCollectionView() {
        let layout = UICollectionViewCompositionalLayout { _, _ in
            let itemSize  = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(58))
            let item      = NSCollectionLayoutItem(layoutSize: itemSize)
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(58))
            let group     = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            let section   = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 0, bottom: 0, trailing: 0)
            return section
        }

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor(.backgroundDefault)
        collectionView.delegate = self
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(childNavigationBar.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }

        collectionView.register(TermsListCell.self, forCellWithReuseIdentifier: TermsListCell.reuseIdentifier)

        dataSource = .init(collectionView: collectionView) { cv, indexPath, item in
            guard let cell = cv.dequeueReusableCell(
                withReuseIdentifier: TermsListCell.reuseIdentifier,
                for: indexPath
            ) as? TermsListCell else {
                return nil   // 캐스팅 실패 시 nil -> diffable이 안전하게 무시
            }
            cell.configure(item)
            return cell
        }
    }

    private func applySnapshot() {
        var snap = NSDiffableDataSourceSnapshot<Section, TermsItem>()
        snap.appendSections([.main])
        snap.appendItems(items)
        dataSource.apply(snap, animatingDifferences: false)
    }

    private func openDetail(_ item: TermsItem) {
        guard let url = URL(string: item.urlString) else { return }
        let vc = AgreementDetailWebViewController(title: item.title, url: url)
        navigationController?.pushHidesBottomBarViewController(vc, animated: true)
    }
}

extension TermsListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let item = dataSource.itemIdentifier(for: indexPath) { openDetail(item) }
    }
}

extension TermsListViewController: ChildNavigationBarDelegate {
    func childNavigationBarDidTapBack(_ navigationBar: ChildNavigationBar) {
        navigationController?.popViewController(animated: true)
    }
}

extension TermsListViewController: UIGestureRecognizerDelegate {}
