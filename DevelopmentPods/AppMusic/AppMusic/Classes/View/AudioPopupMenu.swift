//
//  AudioPopupMenu.swift
//  AppMusic
//
//  Created by Archer on 2019/2/25.
//

import Fate
import FOLDin
import AudioService

protocol AudioPopupMenuDelegate: class {
    /// 将要播放下一曲
    func popupMenuWillPlayNext(_ menu: AudioPopupMenu)
    /// 将要添加歌曲
    func popupMenu(_ menu: AudioPopupMenu, willAddAudioToPlayList audio: MusicInfo)
    /// 将要下载歌曲
    func popupMenu(_ menu: AudioPopupMenu, willDownloadAudio audio: MusicInfo) 
}

class AudioPopupMenu: UIView, ValueCell {
    
    weak var delegate: AudioPopupMenuDelegate?
    
    private lazy var titleLabel: UILabel = {
        let v = UILabel()
        v.textAlignment = .left
        addSubview(v)
        return v
    }()
    
    private lazy var topLine: UIView = {
        let v = UIView()
        v.backgroundColor = GLarkdef.gray_EAEAEA
        addSubview(v)
        return v
    }()
    
    private lazy var nextButton: UIButton = {
        let v = UIButton()
        v.setTitle("播放下一首", for: .normal)
        v.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        v.setTitleColor(GLarkdef.gray_9999A2, for: .normal)
        v.setImage(UIImage(nameInBundle: "popup_menu_next"), for: .normal)
        v.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        addSubview(v)
        return v
    }()
    
    private lazy var addButton: UIButton = {
        let v = UIButton()
        v.setTitle("添加到歌单", for: .normal)
        v.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        v.setTitleColor(GLarkdef.gray_9999A2, for: .normal)
        v.setImage(UIImage(nameInBundle: "popup_menu_add"), for: .normal)
        v.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        addSubview(v)
        return v
    }()
    
    private lazy var downloadButton: UIButton = {
        let v = UIButton()
        v.setTitle("下载", for: .normal)
        v.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        v.setTitleColor(GLarkdef.gray_9999A2, for: .normal)
        v.setImage(UIImage(nameInBundle: "popup_menu_download"), for: .normal)
        v.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        addSubview(v)
        return v
    }()
    
    private lazy var bottomLine: UIView = {
        let v = UIView()
        v.backgroundColor = GLarkdef.gray_EAEAEA
        addSubview(v)
        return v
    }()
    
    private lazy var cancelButton: UIButton = {
        let v = UIButton()
        v.setTitle("取消", for: .normal)
        v.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        v.setTitleColor(GLarkdef.black_333345, for: .normal)
        v.addTarget(self, action: #selector(dismissal), for: .touchUpInside)
        addSubview(v)
        return v
    }()

    private let viewModel: AudioPopupMenuViewModelType = AudioPopupMenuViewModel()
    
    @objc private func buttonTapped(_ sender: UIButton) {
        guard let audio = viewModel.outputs.audio else { return }
        if sender === nextButton {
            delegate?.popupMenuWillPlayNext(self)
        }else if sender === addButton {
            delegate?.popupMenu(self, willAddAudioToPlayList: audio)
        } else {
            delegate?.popupMenu(self, willDownloadAudio: audio)
        }
    }
    
    @objc private func dismissal() {
        fd.popupView?.dismissal()
    }
    
    func configureWith(value: MusicInfo) {
        viewModel.inputs.configure(value: value)
        titleLabel.attributedText = viewModel.outputs.titleAttributedText
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        nextButton.fd.setTitleAlignment(.bottom, withOffset: 15)
        addButton.fd.setTitleAlignment(.bottom, withOffset: 15)
//        downloadButton.fd.setTitleAlignment(.bottom, withOffset: 15)
    }

    init() {
        super.init(frame: .zero)
        backgroundColor = .white
        layer.cornerRadius = 10
        cancelButton.snp.makeConstraints { (make) in
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom)
            } else {
                make.bottom.equalToSuperview()
            }
            make.left.right.equalToSuperview()
            make.height.equalTo(58)
        }
        bottomLine.snp.makeConstraints { (make) in
            make.bottom.equalTo(cancelButton.snp.top)
            make.left.right.equalToSuperview()
            make.height.equalTo(0.5)
        }
        nextButton.snp.makeConstraints { (make) in
            make.left.equalTo(12)
            make.bottom.equalTo(bottomLine.snp.top)
            make.size.equalTo(CGSize(width: 70, height: 90))
        }
        addButton.snp.makeConstraints { (make) in
            make.left.equalTo(nextButton.snp.right).offset(28)
            make.centerY.size.equalTo(nextButton)
        }
//        downloadButton.snp.makeConstraints { (make) in
//            make.left.equalTo(addButton.snp.right).offset(28)
//            make.centerY.size.equalTo(addButton)
//        }
        topLine.snp.makeConstraints { (make) in
            make.bottom.equalTo(nextButton.snp.top).offset(-22)
            make.left.right.height.equalTo(bottomLine)
        }
        titleLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(topLine.snp.top)
            make.left.equalTo(12)
            make.right.equalTo(-12)
            make.height.equalTo(43)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
