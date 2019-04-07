//
//  AudioSearchResultCell.swift
//  AppMusic
//
//  Created by Archer on 2019/2/25.
//

import Fate
import AudioService

protocol AudioSearchResultCellDelegate: class {
    /// 将要改变喜欢状态
    func searchResultCell(_ cell: AudioSearchResultCell, willChangeLikeStatus isLike: Bool)
    /// 将要打开菜单
    func searchResultCellWillOpenPopupMenu(_ cell: AudioSearchResultCell)
}

class AudioSearchResultCell: UITableViewCell, ValueCell {

    weak var delegate: AudioSearchResultCellDelegate?
    
    private lazy var nameLabel: UILabel = {
        let v = UILabel()
        v.textAlignment = .left
        v.textColor = GLarkdef.black_333345
        v.font = UIFont.systemFont(ofSize: 16)
        contentView.addSubview(v)
        return v
    }()
    
    private lazy var artistLabel: UILabel = {
        let v = UILabel()
        v.textAlignment = .left
        v.textColor = GLarkdef.gray_646580
        v.font = UIFont.systemFont(ofSize: 12)
        contentView.addSubview(v)
        return v
    }()
    
    private lazy var likeButton: UIButton = {
        let v = UIButton()
        v.setImage(UIImage(nameInBundle: "sheet_list_unlike"), for: .normal)
        v.setImage(UIImage(nameInBundle: "sheet_list_like"), for: .selected)
        v.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        v.fd.touchAreaInsets = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 5)
        contentView.addSubview(v)
        return v
    }()
    
    private lazy var moreButton: UIButton = {
        let v = UIButton()
        v.setImage(UIImage(nameInBundle: "sheet_list_more"), for: .normal)
        v.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        v.fd.touchAreaInsets = UIEdgeInsets(top: 15, left: 5, bottom: 15, right: 15)
        contentView.addSubview(v)
        return v
    }()
    
    private lazy var lineView: UIView = {
        let v = UIView()
        v.backgroundColor = GLarkdef.gray_EAEAEA
        contentView.addSubview(v)
        return v
    }()
    
    private lazy var viewModel: AudioSearchResultCellViewModelType = AudioSearchResultCellViewModel()
    
    @objc private func buttonTapped(_ sender: UIButton) {
        if sender === likeButton {
            sender.isSelected = !sender.isSelected
            delegate?.searchResultCell(self, willChangeLikeStatus: sender.isSelected)
        } else {
            delegate?.searchResultCellWillOpenPopupMenu(self)
        }
    }
    
    func configureWith(value: MusicInfo) {
        viewModel.inputs.configure(value: value)
        nameLabel.attributedText = viewModel.outputs.nameAttributedText
        artistLabel.attributedText = viewModel.outputs.artistAttributedText
        likeButton.isSelected = viewModel.outputs.isCollection
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        buildUI()
    }
    
    private func buildUI() {
        selectionStyle = .none
        backgroundColor = .white
        moreButton.snp.makeConstraints { (make) in
            make.right.equalTo(-15)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 18, height: 18))
        }
        likeButton.snp.makeConstraints { (make) in
            make.right.equalTo(moreButton.snp.left).offset(-20)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 15, height: 15))
        }
        nameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(10)
            make.bottom.equalTo(snp.centerY).offset(-3.5)
            make.right.equalTo(likeButton.snp.left).offset(-15)
            make.height.equalTo(17)
        }
        artistLabel.snp.makeConstraints { (make) in
            make.width.equalTo(nameLabel).multipliedBy(0.75)
            make.top.equalTo(snp.centerY).offset(3.5)
            make.left.equalTo(nameLabel)
            make.height.equalTo(13)
        }
        lineView.snp.makeConstraints { (make) in
            make.bottom.right.equalToSuperview()
            make.left.equalTo(nameLabel)
            make.height.equalTo(0.5)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
