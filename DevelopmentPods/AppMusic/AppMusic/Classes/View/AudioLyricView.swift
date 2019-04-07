//
//  AudioLyricView.swift
//  AppMusic
//
//  Created by Archer on 2019/2/25.
//

import UIKit
import AudioService

protocol AudioLyricViewDataSource: class {
    /// 有多少句歌词
    func lyricItemsForLyricView(_ lyricView: AudioLyricView) -> [AudioLyricItemProtocol]?
    /// 当前播放的歌词在所有歌词中的位置
    func currentLyricItemIndexForLyricView(_ lyricView: AudioLyricView) -> Int?
}

protocol AudioLyricViewDelegate: class {
    /// 点击了视图
    func lyricViewDidTapped(_ lyricView: AudioLyricView)
}

class AudioLyricView: UIView {

    weak var delegate: AudioLyricViewDelegate?
    weak var dataSource: AudioLyricViewDataSource?
    
    private lazy var tableView: UITableView = {
        let v = UITableView()
        v.delegate = self
        v.dataSource = self
        v.separatorStyle = .none
        v.backgroundColor = .clear
        v.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        addSubview(v)
        return v
    }()
    
    private lazy var tipsLabel: UILabel = {
        let v = UILabel()
        v.text = "歌词加载中..."
        v.textAlignment = .center
        v.font = UIFont.systemFont(ofSize: 15)
        v.textColor = UIColor.white.withAlphaComponent(0.7)
        addSubview(v)
        return v
    }()
    
    private lazy var lastItemIndex = -1
    
    func reloadData() {
        tableView.reloadData()
        reloadCurrentItem()
    }
    
    // 更新当前行
    func reloadCurrentItem() {
        if !tableView.isDragging && !tableView.isTracking {
            let curLyricItemIndex = dataSource?.currentLyricItemIndexForLyricView(self) ?? 0
            if lastItemIndex != curLyricItemIndex {
                tableView.reloadData()
                lastItemIndex = curLyricItemIndex
                tableView.scrollToRow(at: IndexPath(row: 5 + curLyricItemIndex, section: 0), at: .middle, animated: true)
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        tableView.frame = bounds
        tipsLabel.height = 30
        tipsLabel.width = width - 40
        tipsLabel.centerX = width / 2
        tipsLabel.centerY = height / 2
    }
    
    @objc private func lyricViewTapped() {
        delegate?.lyricViewDidTapped(self)
    }
    
    init() {
        super.init(frame: .zero)
        addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                    action: #selector(lyricViewTapped)))
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        gestureRecognizers?.forEach {
            removeGestureRecognizer($0)
        }
    }
}

extension AudioLyricView: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let lyricItems = dataSource?.lyricItemsForLyricView(self)
        if let lyricItems = lyricItems {
            if lyricItems.isEmpty {
                tipsLabel.isHidden = false
                tipsLabel.text = "纯音乐，请欣赏"
            } else {
                tipsLabel.isHidden = true
            }
        } else {
            tipsLabel.isHidden = false
            tipsLabel.text = "歌词加载中..."
        }
        return (lyricItems?.count ?? 0) + 10 // 多加10是为了留白
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.textColor = UIColor.white.withAlphaComponent(0.5)
        cell.textLabel?.font = UIFont.systemFont(ofSize: 14)
        cell.textLabel?.textAlignment = .center
        cell.textLabel?.numberOfLines = 0
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        if let lyricItems = dataSource?.lyricItemsForLyricView(self) {
            if indexPath.row < 5 || indexPath.row > lyricItems.count + 4 {
                cell.textLabel?.text = ""
            } else {
                cell.textLabel?.text = lyricItems[indexPath.row - 5].contents
                if let curLyricItemIndex = dataSource?.currentLyricItemIndexForLyricView(self) {
                    if indexPath.row == curLyricItemIndex + 5 {
                        cell.textLabel?.textColor = .white
                        cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
                    }
                }
            }
        } else {
            cell.textLabel?.text = ""
        }
        return cell
    }
}
