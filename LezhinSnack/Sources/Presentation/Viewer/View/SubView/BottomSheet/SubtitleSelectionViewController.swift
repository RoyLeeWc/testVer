//
//  SubtitleSelectionViewController.swift
//  LezhinSnack
//
//  Created by jinu0115 on 4/23/25.
//

// SubtitleSelectionViewController.swift
import UIKit
import AVKit
import SnapKit

final class SubtitleSelectionViewController: UIViewController {
    private let options: [AVMediaSelectionOption]
    private let selectedOption: AVMediaSelectionOption?   // 추가
    var selectionHandler: ((AVMediaSelectionOption?) -> Void)?

    private let tableView = UITableView()
    
    private let grabberView = LZSnackGrabberView()
    
    private let headerLabel: UILabel = {
        let label = UILabel()
        label.font = .pretendardBold(size: 20)
        label.textColor = .white
        label.textAlignment = .left
        label.text = "자막 설정"
        return label
    }()
    
    private let checkImageView: UIImageView = {
        let imageView = UIImageView()
        let image = UIImage(named: "ic_checked_white")
        
        imageView.backgroundColor = .clear
        imageView.image = image
        
        return imageView
    }()

    init(options: [AVMediaSelectionOption], selectedOption: AVMediaSelectionOption?) {
        self.options = options
        self.selectedOption = selectedOption
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(.backgroundRaisedDefault)
        setupUI()
    }

    private func setupUI() {
        setupGrabberView()
        
        view.addSubview(headerLabel)
        headerLabel.snp.makeConstraints { make in
            make.top.equalTo(grabberView.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(48)
        }
        
        tableView.dataSource = self
        tableView.backgroundColor = UIColor(.clear)
        
        tableView.separatorStyle = .none // 구분선 제거
        tableView.isScrollEnabled = false
        tableView.register(SubtitleCell.self, forCellReuseIdentifier: SubtitleCell.reuseIdentifier)
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(headerLabel.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        if let sel = selectedOption,
           let idx = options.firstIndex(of: sel) {
            let ip = IndexPath(row: idx + 1, section: 0) // row 0은 '자막 끄기'
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
extension SubtitleSelectionViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count + 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt ip: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SubtitleCell.reuseIdentifier, for: ip) as? SubtitleCell else { return UITableViewCell() }
        let title: String = ip.row == 0 ? "자막 끄기" : options[ip.row - 1].displayName
        cell.configure(text: title)
        cell.selectionStyle = .none
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt ip: IndexPath) {
        let selected: AVMediaSelectionOption? = (ip.row == 0 ? nil : options[ip.row - 1])
        
        onMainAfter(delay: 0.3 ) { [weak self] in
            self?.selectionHandler?(selected)
            //self?.dismiss(animated: true)
        }
    }

    // 고정 높이 58
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 58
    }
}

// MARK: - SubtitleCell
private class SubtitleCell: UITableViewCell {
    static let reuseIdentifier = "SubtitleCell"
    
    private let paddedLabel: UILabel = {
        let label = UILabel()
        label.font = .pretendardMedium(size: 16)
        label.textColor = .white
        label.backgroundColor = .clear
        label.numberOfLines = 1
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
            make.trailing.equalToSuperview().offset(16)
            make.trailing.equalTo(checkImageView.snp.leading)
        }
    }
    required init?(coder: NSCoder) { fatalError() }

    func configure(text: String) {
        paddedLabel.text = text
    }
    
    // 선택 시 강조 스타일
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        checkImageView.isHidden = !selected
        if selected {
            contentView.backgroundColor = UIColor(.fillTransparentPressed)
        } else {
            contentView.backgroundColor = .clear
        }
    }
}
