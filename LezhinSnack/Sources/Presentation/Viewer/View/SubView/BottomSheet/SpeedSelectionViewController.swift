//
//  SpeedSelectionViewController.swift
//  LezhinSnack
//
//  Created by jinu0115 on 4/23/25.
//

import UIKit
import SnapKit

final class SpeedSelectionViewController: UIViewController {
    private let playbackRates: [Float]
    private let selectedRate: Float
    
    var selectionHandler: ((Float) -> Void)?

    private let grabberView = LZSnackGrabberView()
    
    private let headerLabel: UILabel = {
        let label = UILabel()
        label.font = .pretendardBold(size: 20)
        label.textColor = .white
        label.textAlignment = .left
        label.text = "재생 속도"
        return label
    }()

    private let tableView = UITableView()

    init(playbackRates: [Float], selectedRate: Float) {
        self.playbackRates = playbackRates
        self.selectedRate = selectedRate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(.backgroundRaisedDefault)
        setupUI()
    }

    private func setupUI() {
        setupGrabberView()
        
        // Header
        view.addSubview(headerLabel)
        headerLabel.snp.makeConstraints { make in
            make.top.equalTo(grabberView.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(48)
        }
        
        // TableView
        tableView.dataSource = self
        tableView.backgroundColor = UIColor(.clear)
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false
        tableView.register(SpeedCell.self, forCellReuseIdentifier: SpeedCell.reuseIdentifier)
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(headerLabel.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview()//.inset(16)
            make.bottom.equalToSuperview()
        }
        
        if let idx = playbackRates.firstIndex(of: selectedRate) {
            let ip = IndexPath(row: idx, section: 0)
            tableView.selectRow(at: ip, animated: false, scrollPosition: .middle)
        }
        
        tableView.delegate = self
    }
    
    private func setupGrabberView() {
        view.addSubview(grabberView)
        grabberView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(28)
        }
    }
    
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension SpeedSelectionViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tv: UITableView, numberOfRowsInSection section: Int) -> Int {
        playbackRates.count
    }

    func tableView(_ tv: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tv.dequeueReusableCell(withIdentifier: SpeedCell.reuseIdentifier, for: indexPath) as? SpeedCell else { return UITableViewCell()}
        let rate = playbackRates[indexPath.row]
        cell.configure(text: String(format: "%.1fx", rate))
        return cell
    }

    func tableView(_ tv: UITableView, didSelectRowAt indexPath: IndexPath) {
        let rate = playbackRates[indexPath.row]
        
        onMainAfter(delay: 0.3 ) { [weak self] in
            self?.selectionHandler?(rate)
            //self?.dismiss(animated: true)
        }
    }

    // 고정 높이 58
    func tableView(_ tv: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        58
    }
}

// MARK: - SpeedCell
private class SpeedCell: UITableViewCell {
    static let reuseIdentifier = "SpeedCell"
    
    private let paddedLabel: UILabel = {
        let label = UILabel()
        label.font = .pretendardMedium(size: 16)
        label.textColor = .white
        label.numberOfLines = 1
        label.backgroundColor = .clear
        return label
    }()
    
    private let checkImageView: UIImageView = {
        let imageView = UIImageView()
        let image = UIImage(named: "ic_checked_white")
        
        imageView.backgroundColor = .clear
        imageView.image = image
        
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .clear
        backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(checkImageView)
        checkImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.width.height.equalTo(24)
            make.trailing.equalToSuperview().offset(-16)
        }
        checkImageView.isHidden = true
        
        contentView.addSubview(paddedLabel)
        paddedLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalTo(checkImageView.snp.leading)
        }
        
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(text: String) {
        paddedLabel.text = text
    }
    
    // 선택 시 강조 스타일
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // 선택된 셀만 체크 이미지 보이기
        checkImageView.isHidden = !selected
        
        if selected {
            contentView.backgroundColor = UIColor(.fillTransparentPressed)
        } else {
            contentView.backgroundColor = .clear
        }
        
    }
    
//    override var isSelected: Bool {
//        didSet {
//            if isSelected {
//                contentView.backgroundColor = UIColor(.darkGray333)
//            } else {
//                contentView.backgroundColor = .clear
//            }
//        }
//    }
}

