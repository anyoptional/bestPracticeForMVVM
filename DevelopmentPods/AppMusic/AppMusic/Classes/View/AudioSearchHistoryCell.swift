//
//  AudioSearchHistoryCell.swift
//  AppMusic
//
//  Created by Archer on 2019/2/25.
//

import Fate
import YYKit

protocol AudioSearchHistoryCellDelegate: class {
    /// 将要触发搜索
    func historyCell(_ cell: AudioSearchHistoryCell, willTriggerSearchAt keyword: String)
}

class AudioSearchHistoryCell: UITableViewCell, ValueCell {

    private lazy var keywordsLabel: YYLabel = {
        let v = YYLabel()
        v.textContainerInset = UIEdgeInsets(top: 6, left: 9, bottom: 12, right: 9)
        v.numberOfLines = 0
        v.displaysAsynchronously = true
        v.textAlignment = .left
        contentView.addSubview(v)
        return v
    }()
    
    weak var delegate: AudioSearchHistoryCellDelegate?
    
    private lazy var viewModel: AudioSearchHistoryCellViewModelType = AudioSearchHistoryCellViewModel()
    
    func configureWith(value: [String]) {
        viewModel.inputs.configure(value: value)
        keywordsLabel.attributedText = viewModel.outputs.attributedText
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        
        keywordsLabel.snp.makeConstraints { (make) in
            make.top.equalTo(10)
            make.bottom.equalTo(-5)
            make.left.right.equalToSuperview()
        }
        
        keywordsLabel.highlightTapAction = { [weak self] (container, attrString, range, rect) in
            guard let `self` = self else { return }
            let keyword = attrString.attributedSubstring(from: range).string
            self.delegate?.historyCell(self, willTriggerSearchAt: keyword.trimmed)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
