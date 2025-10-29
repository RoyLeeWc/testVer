//
//  ChangeLanguageViewController.swift
//  BalconyShortForm
//
//  Created by jinu0115 on 3/12/25.
//


import UIKit
import SnapKit
import Combine
import SwiftyUserDefaults

final class ChangeLanguageViewController: UIViewController, ChildNavigationBarPresentable {
    // 언어 리스트 (코드, 표시명)
    private let languages: [(code: String, title: String)] = [
        (LanguageCode.korean, "한국어"),
        (LanguageCode.english, "English"),
        (LanguageCode.japanese, "日本語"),
        (LanguageCode.simplifiedChinese, "中文")
    ]
    // 현재 선택된 언어 코드
    private let selectedCode: String = Defaults.isUserSetLanguageCode ?? false
        ? Defaults.currentSetLanguageCode
        : Locale.current.languageCode ?? "ko"
    
    let childNavigationBar = ChildNavigationBar()
    private let tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(.backgroundDefault)
        setupChildNavigationBar()
        childNavigationBar.delegate = self
        childNavigationBar.titleLabel.text = "앱바_언어변경".localized
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        setupTableView()
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false
        tableView.register(LanguageCell.self, forCellReuseIdentifier: LanguageCell.reuseIdentifier)
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(childNavigationBar.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        // 초기 선택 표시
        if let index = languages.firstIndex(where: { $0.code == selectedCode }) {
            let indexPath = IndexPath(row: index, section: 0)
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .middle)
        }
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension ChangeLanguageViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        languages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
                withIdentifier: LanguageCell.reuseIdentifier,
                for: indexPath
            ) as? LanguageCell
        else { return UITableViewCell() }
        
        let language = languages[indexPath.row]
        cell.configure(text: language.title)
        // 재사용 시 선택 상태 업데이트
        cell.setSelected(language.code == selectedCode, animated: false)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let language = languages[indexPath.row]
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            Defaults.isUserSetLanguageCode = true
            Defaults.currentSetLanguageCode = language.code
            
            
            
            AppContext.shared.restartApp()
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        58
    }
}

// MARK: - LanguageCell
private class LanguageCell: UITableViewCell {
    static let reuseIdentifier = "LanguageCell"
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .pretendardMedium(size: 16)
        label.textColor = .white
        return label
    }()
    
    private let checkImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "ic_checked_white")
        imageView.isHidden = true
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(checkImageView)
        
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(16)
        }
        checkImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(16)
            make.width.height.equalTo(24)
        }
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func configure(text: String) {
        titleLabel.text = text
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        checkImageView.isHidden = !selected
        contentView.backgroundColor = selected
            ? UIColor(.fillTransparentPressed)
            : .clear
    }
}

// MARK: - ChildNavigationBarDelegate
extension ChangeLanguageViewController: ChildNavigationBarDelegate {
    func childNavigationBarDidTapBack(_ navigationBar: ChildNavigationBar) {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - UIGestureRecognizerDelegate
extension ChangeLanguageViewController: UIGestureRecognizerDelegate {}


import Foundation
import SwiftyUserDefaults

private var onceToken: Bool = false

final class LanguageBundle: Bundle {
  override func localizedString(
    forKey key: String,
    value: String?,
    table tableName: String?
  ) -> String {
    let lang = Defaults.currentSetLanguageCode
    // 선택된 언어 번들을 찾아 반환
    if
      let path = Bundle.main.path(forResource: lang, ofType: "lproj"),
      let bundle = Bundle(path: path)
    {
      return bundle.localizedString(forKey: key, value: value, table: tableName)
    }
    // 실패 시 기본 동작
    return super.localizedString(forKey: key, value: value, table: tableName)
  }
}

extension Bundle {
    private static let swizzleLocalizationImplementation: Void = {
        let originalSelector = #selector(localizedString(forKey:value:table:))
        let swizzledSelector = #selector(swizzled_localizedString(forKey:value:table:))

        guard
            let originalMethod = class_getInstanceMethod(Bundle.self, originalSelector),
            let swizzledMethod = class_getInstanceMethod(Bundle.self, swizzledSelector)
        else { return }

        method_exchangeImplementations(originalMethod, swizzledMethod)
    }()

    @objc private func swizzled_localizedString(
        forKey key: String,
        value: String?,
        table tableName: String?
    ) -> String {
        let lang = Defaults.currentSetLanguageCode
        if
            let path = Bundle.main.path(forResource: lang, ofType: "lproj"),
            let bundle = Bundle(path: path)
        {
            return bundle.swizzled_localizedString(forKey: key, value: value, table: tableName)
        }
        // 실패 시 원래 구현(스위즐된 메서드) 호출
        return swizzled_localizedString(forKey: key, value: value, table: tableName)
    }

    /// 앱 시작 시점에 한 번만 호출하세요.
    static func enableRuntimeLocalization() {
        _ = self.swizzleLocalizationImplementation
    }
}
