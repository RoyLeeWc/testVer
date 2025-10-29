//
//  NavigationBarProtocol.swift
//  BalconyShortForm
//
//  Created by 신진우 on 3/11/25.
//

import UIKit


protocol RootNavigationBarPresentable {
    var rootNavigationBar: RootNavigationBar { get }
    func setupRootNavigationBar()
}

protocol RootNavigationBarDelegate: AnyObject {
    func rootNavigationBarDidTapLogin       (_ navigationBar: RootNavigationBar)
    func rootNavigationBarDidTapSearch      (_ navigationBar: RootNavigationBar)
    func rootNavigationBarDidTapMyWallet    (_ navigationBar: RootNavigationBar)
    func rootNavigationBarDidTapViewer      (_ navigationBar: RootNavigationBar)
}

extension RootNavigationBarPresentable where Self: UIViewController {
    func setupRootNavigationBar() {
        view.addSubview(rootNavigationBar)
        rootNavigationBar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(LZSConstant.NavigationBarHeight)
        }
    }
}

protocol HomeRootNavigationBarPresentable {
    var rootNavigationBar: HomeRootNavigationBar { get }
    func setupRootNavigationBar()
}

protocol HomeRootNavigationBarDelegate: AnyObject {
    func rootNavigationBarDidTapLogo       (_ navigationBar: HomeRootNavigationBar)
    func rootNavigationBarDidTapSearch     (_ navigationBar: HomeRootNavigationBar)
}


extension HomeRootNavigationBarPresentable where Self: UIViewController {
    func setupRootNavigationBar() {
        view.addSubview(rootNavigationBar)
        rootNavigationBar.snp.makeConstraints { make in
            make.top.equalTo(view.snp.top)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(LZSConstant.HomeNavigationBarHeight)
        }
    }
}

protocol TitleRootNavigationBarPresentable {
    var rootNavigationBar: TitleRootNavigationBar { get }
    func setupRootNavigationBar()
}

protocol TitleRootNavigationBarDelegate: AnyObject {
//    func rootNavigationBarDidTapLogo       (_ navigationBar: HomeRootNavigationBar)
//    func rootNavigationBarDidTapSearch     (_ navigationBar: HomeRootNavigationBar)
}

extension TitleRootNavigationBarPresentable where Self: UIViewController {
    func setupRootNavigationBar() {
        view.addSubview(rootNavigationBar)
        rootNavigationBar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(LZSConstant.TitleNavigationBarHeight)
        }
    }
}

protocol ChildNavigationBarPresentable {
    var childNavigationBar: ChildNavigationBar { get }
    func setupChildNavigationBar()
}

protocol ChildNavigationBarDelegate: AnyObject {
    func childNavigationBarDidTapBack(_ navigationBar: ChildNavigationBar)
}

extension ChildNavigationBarPresentable where Self: UIViewController {
    func setupChildNavigationBar() {
        view.addSubview(childNavigationBar)
        childNavigationBar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(LZSConstant.NavigationBarHeight)
        }
    }
}


protocol ChildRightCloseNavigationBarPresentable {
    var childNavigationBar: ChildRightCloseNavigationBar { get }
    func setupChildNavigationBar()
}

protocol ChildRightCloseNavigationBarDelegate: AnyObject {
    func childNavigationBarDidTapClose(_ navigationBar: ChildRightCloseNavigationBar)
}

extension ChildRightCloseNavigationBarPresentable where Self: UIViewController {
    func setupChildNavigationBar() {
        view.addSubview(childNavigationBar)
        childNavigationBar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(LZSConstant.NavigationBarHeight)
        }
    }
}
