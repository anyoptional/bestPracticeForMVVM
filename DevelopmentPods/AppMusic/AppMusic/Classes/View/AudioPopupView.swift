//
//  AudioPopupView.swift
//  AppMusic
//
//  Created by Archer on 2019/2/25.
//

import Fate
import AudioService

protocol AudioPopupViewDataSource: class {
    /// 当前播放模式
    func playModeForPopupView(_ popupView: AudioPopupView) -> AudioStreamerPlayMode
    /// 当前播放列表
    func playListForPopupView(_ popupView: AudioPopupView) -> [MusicInfo]?
    /// 当前播放位置
    func currentPlayIndexForPopupView(_ popupView: AudioPopupView) -> Int?
}

protocol AudioPopupViewDelegate: class {
    /// 将要切换播放模式
    func popupViewWillChangePlayMode(_ popupView: AudioPopupView)
    /// 将要清空播放列表
    func popupViewWillClearPlayList(_ popupView: AudioPopupView)
    /// 点击了下标为index的歌曲
    func popupView(_ popupView: AudioPopupView, didSelectAudioAtIndex index: Int)
    /// 将要删除index处的音频
    func popupViewWillRemoveAudio(at index: Int)
}

class AudioPopupView: UIView {
    
    weak var delegate: AudioPopupViewDelegate?
    weak var dataSource: AudioPopupViewDataSource?
    
    private lazy var modeButton: UIButton = {
        let v = UIButton()
        v.setTitle("随机播放(~~)", for: .normal)
        v.setImage(UIImage(nameInBundle: "audio_random"), for: .normal)
        v.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        v.setTitleColor(GLarkdef.gray_646580, for: .normal)
        v.frame = CGRect(x: 1, y: 15, width: 130, height: 20)
        v.fd.setTitleAlignment(.right, withOffset: 10)
        v.addTarget(self, action: #selector(modeButtonTapped), for: .touchUpInside)
        return v
    }()
    
    private lazy var clearButton: UIButton = {
        let v = UIButton()
        v.setImage(UIImage(nameInBundle: "audio_clear_list"), for: .normal)
        v.addTarget(self, action: #selector(clearButtonTapped), for: .touchUpInside)
        return v
    }()
    
    private lazy var closeButton: UIButton = {
        let v = UIButton()
        v.setTitle("关闭", for: .normal)
        v.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        v.setTitleColor(GLarkdef.black_333345, for: .normal)
        v.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        return v
    }()
    
    private lazy var tableView: UITableView = {
        let v = UITableView(frame: .zero, style: .plain)
        v.rowHeight = 45
        v.delegate = self
        v.dataSource = self
        v.backgroundColor = .clear
        v.tableFooterView = UIView()
        v.separatorStyle = .singleLine
        v.separatorColor = GLarkdef.gray_EAEAEA
        if #available(iOS 11, *) {
            v.contentInsetAdjustmentBehavior = .never
        }
        v.register(AudioPopupCell.self, forCellReuseIdentifier: "cell")
        return v
    }()
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        tableView.reloadData()
        updateUI()
        DispatchQueue.main.asyncAfter(deadline: 0.25) {
            self.scrollsToPlayingAduio()
        }
    }
    
    init() {
        super.init(frame: .zero)
        buildUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NSLog("%@ is deallocating...", className())
    }
}

extension AudioPopupView {
    private func updateUI() {
        let playList = dataSource?.playListForPopupView(self)
        let playMode = dataSource?.playModeForPopupView(self) ?? .singleLoop
        let title = playMode.description + "(\(playList?.count ?? 0))"
        modeButton.setTitle(title, for: .normal)
        switch playMode {
        case .random:
            modeButton.setImage(UIImage(nameInBundle: "audio_random"), for: .normal)
        case .singleLoop:
            modeButton.setImage(UIImage(nameInBundle: "audio_single_loop"), for: .normal)
        case .sequenceLoop:
            modeButton.setImage(UIImage(nameInBundle: "audio_sequence_loop"), for: .normal)
        }
    }
    
    private func scrollsToPlayingAduio() {
        if let curIndex = dataSource?.currentPlayIndexForPopupView(self) {
            tableView.scrollToRow(at: IndexPath(row: curIndex, section: 0), at: .middle, animated: true)
        }
    }
}

extension AudioPopupView {
    @objc private func modeButtonTapped() {
        delegate?.popupViewWillChangePlayMode(self)
        updateUI()
    }
    
    @objc private func clearButtonTapped() {
        let alertVc = UIAlertController(title: "确定要清空播放列表？", message: nil, preferredStyle: .alert)
        alertVc.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        alertVc.addAction(UIAlertAction(title: "确定", style: .destructive, handler: { _ in
            self.delegate?.popupViewWillClearPlayList(self)
            self.tableView.reloadData()
        }))
        // 不是个好主意只是没有什么好法子
        self.viewController?.present(alertVc, animated: true, completion: nil)
    }
    
    @objc private func closeButtonTapped() {
        fd.popupView?.dismissal()
    }
}

extension AudioPopupView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.popupView(self, didSelectAudioAtIndex: indexPath.row)
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource?.playListForPopupView(self)?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! AudioPopupCell
        if indexPath.row == tableView.numberOfRows(inSection: 0) - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: cell.width, bottom: 0, right: 0)
        } else {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        }
        if let audio = (dataSource?.playListForPopupView(self))?[indexPath.row] {
            cell.configureWith(value: audio)
        }
        if let curIndex = dataSource?.currentPlayIndexForPopupView(self) {
            let flag = indexPath.row == curIndex
            cell.configureWith(flag: flag)
        }
        cell.delegate = self
        return cell
    }
}

extension AudioPopupView: AudioPopupCellDelegate {
    func popupCellWillRemoveAudio(_ cell: AudioPopupCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        // 要删除的是当前播放的歌曲
        if indexPath.row == (dataSource?.currentPlayIndexForPopupView(self) ?? -1) {
            delegate?.popupViewWillRemoveAudio(at: indexPath.row)
            tableView.reloadData()
        } else {
            delegate?.popupViewWillRemoveAudio(at: indexPath.row)
            tableView.deleteRow(at: indexPath, with: .automatic)
        }
    }
}

extension AudioPopupView {
    private func buildUI() {
        backgroundColor = .white
        layer.cornerRadius = 10
        
        addSubview(modeButton)
        addSubview(clearButton)
        clearButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(modeButton)
            make.right.equalTo(-18)
            make.size.equalTo(CGSize(width: 18, height: 18))
        }
        let topView = UIView()
        topView.backgroundColor = GLarkdef.gray_EAEAEA
        addSubview(topView)
        topView.snp.makeConstraints { (make) in
            make.top.equalTo(modeButton.snp.bottom).offset(15)
            make.left.right.equalToSuperview()
            make.height.equalTo(0.5)
        }
        addSubview(closeButton)
        closeButton.snp.makeConstraints { (make) in
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom)
            } else {
                make.bottom.equalToSuperview()
            }
            make.left.right.equalToSuperview()
            make.height.equalTo(49)
        }
        let bottomView = UIView()
        bottomView.backgroundColor = GLarkdef.gray_EAEAEA
        addSubview(bottomView)
        bottomView.snp.makeConstraints { (make) in
            make.bottom.equalTo(closeButton.snp.top)
            make.left.right.equalToSuperview()
            make.height.equalTo(0.5)
        }
        addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(topView.snp.bottom)
            make.bottom.equalTo(bottomView.snp.top)
            make.left.right.equalToSuperview()
        }
    }
}

