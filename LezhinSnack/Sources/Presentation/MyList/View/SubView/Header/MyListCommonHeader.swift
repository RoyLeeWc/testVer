//
//  MyListCommonHeader.swift
//  LezhinSnack
//
//  Created by jinu0115 on 4/22/25.
//

import UIKit
import SnapKit

final class MyListCommonHeader: UICollectionReusableView {
    
    let historySortButton: LZSnackSortButton = {
        let button = LZSnackSortButton(option: WatchHistorySortOption.recent)
        guard let rawIcon = UIImage(named: "ic_sort_white")?.withRenderingMode(.alwaysOriginal) else { return button }
        let smallIcon = rawIcon.resized(to: CGSize(width: 18, height: 18))?.withRenderingMode(.alwaysOriginal)
        let customStyle = LZSnackSortButton.Style(icon: smallIcon,
                                                  font: .pretendardMedium(size: 16),
                                                  textColor: .white
        )
        
        button.applyStyle(customStyle)
        return button
    }()
    
    let editButton: LZSnackEditButton = {
        let editButton = LZSnackEditButton()
        editButton.setTitle("편집_버튼_타이틀".localized)
        let customStyle = LZSnackEditButton.Style(
            font: .pretendardMedium(size: 16),
            textColor: .white
        )
        editButton.applyStyle(customStyle)
        editButton.contentHorizontalAlignment = .right
        return editButton
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func setupUI() {
    
        self.addSubview(historySortButton)
        historySortButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalToSuperview().inset(24)
            make.height.equalTo(22)
            make.width.equalTo(150)
        }
        
        self.addSubview(editButton)
        editButton.setTitle("편집_버튼_타이틀".localized)
        editButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.top.equalToSuperview().inset(24)
            make.height.equalTo(22)
            make.width.equalTo(100)
        }
        
    }
    
    
}
