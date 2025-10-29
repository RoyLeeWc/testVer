//
//  LZSnackTableDropDown.swift
//  LezhinSnack
//
//  Created by jinu0115 on 5/21/25.
//

import UIKit
import SnapKit

/// A basic table-based drop-down component showing default UITableViewCells.
public final class LZSnackDropDown: UIView {
    
    
    @Published var isShowDropDown: Bool = false
    
    // MARK: - Public API
    public weak var anchorView: UIView?
    public var dataSource: [String] = [] {
        didSet {
            tableView.reloadData()
            updateHeight()
        }
    }
    public var selectionAction: ((Int, String) -> Void)?

    // MARK: - Private UI
    private let backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .black.withAlphaComponent(0.3)
        view.alpha = 0
        view.isUserInteractionEnabled = true
        return view
    }()
    
    private let tableView = UITableView()
    private var heightConstraint: Constraint?

    // MARK: - Init
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    private func commonInit() {
        // dim background
        backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        backgroundView.alpha = 0

        // table view setup
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 48
        tableView.separatorInset = .zero
        tableView.separatorStyle = .none
        
        addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        backgroundColor = UIColor(.backgroundRaisedHigh)
        
        roundCorners(cornerRadius: 4)
        
        layer.borderWidth = 1
        layer.borderColor = UIColor(.borderSubtler).cgColor
        
        tableView.backgroundColor = UIColor(.backgroundRaisedHigh)
        tableView.bounces = false
        
        tableView.register(LZSnackDropDownCell.self,
                           forCellReuseIdentifier: LZSnackDropDownCell.reuseIdentifier)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismiss))
        backgroundView.addGestureRecognizer(tap)
    }

    // MARK: - Public Methods
    public func show() {
        guard let anchor = anchorView, let window = anchor.window else { return }
        
        isShowDropDown = true
        
        // 배경뷰 → 드롭다운 순으로 window에 추가
        window.addSubview(backgroundView)
        window.addSubview(self)

        // 전체 화면에 배경뷰
        backgroundView.snp.remakeConstraints { make in
            make.edges.equalToSuperview()
        }
        // 드롭다운 위치
        self.snp.remakeConstraints { make in
            make.top.equalTo(anchor.snp.bottom).offset(4)
            make.leading.trailing.equalTo(anchor)
            heightConstraint = make.height.equalTo(200).constraint
        }
        // 내부 inset
        tableView.snp.remakeConstraints { make in
            make.edges.equalToSuperview().inset(6)
        }
        updateHeight()
        layoutIfNeeded()

        // 배경 fade-in
        UIView.animate(withDuration: 0.25) {
            self.backgroundView.alpha = 1
        }
    }

    @objc public func dismiss() {
        isShowDropDown = false
        
        UIView.animate(withDuration: 0.25, animations: {
            self.backgroundView.alpha = 0
        }) { _ in
            self.backgroundView.removeFromSuperview()
            self.removeFromSuperview()
        }
    }

    // MARK: - Helpers
    private func updateHeight() {
        let contentHeight = tableView.contentSize.height
        let height = min(contentHeight + 12, 200)
        heightConstraint?.update(offset: height)
        layoutIfNeeded()
    }
}

// MARK: - UITableViewDataSource & Delegate
extension LZSnackDropDown: UITableViewDataSource, UITableViewDelegate {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataSource.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
                      withIdentifier: LZSnackDropDownCell.reuseIdentifier,
                      for: indexPath) as? LZSnackDropDownCell else { return UITableViewCell() }
        cell.configure(with: dataSource[indexPath.row])
        return cell
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectionAction?(indexPath.row, dataSource[indexPath.row])
        dismiss()
    }
}


final class LZSnackDropDownCell: UITableViewCell {
    static let reuseIdentifier = "LZSnackDropDownCell"
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .pretendardRegular(size: 15)
        label.textColor = .white
        label.backgroundColor = .clear
        return label
    }()
    
    private let selectedView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(.fillStaticBlack)
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func setupUI() {
        contentView.backgroundColor = .clear
        backgroundColor = .clear
        
        selectedBackgroundView = selectedView
        
        roundCorners(cornerRadius: 4)
        
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(12)
            make.centerY.equalToSuperview()
        }
    }
    
    func configure(with text: String) {
        titleLabel.text = text
    }
}
