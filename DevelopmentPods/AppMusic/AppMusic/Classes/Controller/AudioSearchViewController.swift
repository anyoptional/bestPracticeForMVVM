//
//  AudioSearchViewController.swift
//  AppMusic
//
//  Created by Archer on 2019/2/25.
//

import Fate
import Fatal
import FOLDin
import RxSwift
import RxCocoa
import SwiftyHUD
import RxSwiftExt
import AudioService

class AudioSearchViewController: UIViewController {
    
    enum Section {
        case result
        case history
    }

    override var prefersNavigationBarStyle: UINavigationBarStyle {
        return .custom
    }
    
    private lazy var searchBar: GLarkSearchBar = {
        let height = 30.toCGFloat()
        let width = kScreenWidth - 60
        return GLarkSearchBar(size: CGSize(width: width, height: height))
    }()
    
    private lazy var tableView: UITableView = {
        let v = UITableView()
        v.separatorStyle = .none
        v.backgroundColor = .clear
        v.keyboardDismissMode = .onDrag
        if #available(iOS 11, *) {
            v.contentInsetAdjustmentBehavior = .never
        }
        v.estimatedRowHeight = UITableView.automaticDimension
        return v
    }()
    
    private var curSection: Section = .history {
        didSet {
           tableView.refreshFooter.isHidden = curSection == .history
        }
    }
    
    private lazy var placeholderView = FDPlaceholderView()
    
    private lazy var streamer = AudioStreamerBuilder().build()
    
    private lazy var dataSource = AudioSearchDataSource()
    private lazy var viewModel: AudioSearchViewModelType = AudioSearchViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buildUI()
        buildNavbar()
        performBinding()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        searchBar.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        KeywordsCache.synchronize()
        searchBar.resignFirstResponder()
    }
    
    deinit {
        NSLog("%@ is deallocating...", className())
    }
}

extension AudioSearchViewController {
    private func performBinding() {
        
        /// 处理缓存
        viewModel.outputs.cacheLoaded
            .subscribeNext(weak: self) { (self)  in
                return { (keywords) in
                    self.placeholderView.state = keywords.isEmpty ? .empty : .completed
                    self.dataSource.load(cachedKeywords: keywords)
                    self.curSection = .history
                    self.tableView.reloadData()
                }
            }.disposed(by: disposeBag)
        
        /// 处理搜索
        searchBar.rx.text.orEmpty
            .distinctUntilChanged()
            // 在1s内不连续搜索
            .throttle(1, scheduler: MainScheduler.instance)
            .subscribeNext(weak: self) { (self) in
                return { (keyword) in
                    // 如果是删光了就加载缓存
                    // 否则就开始搜索
                    if keyword.isBlank {
                        self.loadKeywordsCache()
                    } else {
                        self.searchAudioRelative(by: keyword)
                    }
                }
            }.disposed(by: disposeBag)
        
        /// 处理加载音频
        viewModel.outputs.audioLoaded
            .subscribeNext(weak: self) { (self)  in
                return { (audios) in
                    self.placeholderView.state = audios.isEmpty ? .empty : .completed
                    self.dataSource.load(audioList: audios)
                    self.curSection = .result
                    self.tableView.reloadData()
                }
            }.disposed(by: disposeBag)
        
        /// 处理加载更多
        viewModel.outputs.audioAppended
            .subscribeNext(weak: self) { (self) in
                return { (audios) in
                    self.curSection = .result
                    let indexPaths = self.dataSource.append(audioList: audios)
                    self.tableView.insertRows(at: indexPaths, with: .none)
                }
            }.disposed(by: disposeBag)
        
        // 更新刷新控件状态
        viewModel.outputs.pullToRefreshState
            .bind(to: tableView.refreshFooter.rx.refresh)
            .disposed(by: disposeBag)
        
        /// 处理喜欢
        viewModel.outputs.likeStatus
            .subscribeNext(weak: self) { (self) in
                return { (result) in
                    let flag = result.flag
                    let indexPath = result.indexPath
                    self.dataSource.load(flag: flag, at: indexPath)
                    self.tableView.reloadRow(at: indexPath, with: .none)
                }
            }.disposed(by: disposeBag)
        
        /// 处理错误
        viewModel.outputs.showError
            .subscribeNext(weak: self) { (self) in
                return { (error) in
                    if error.isFailedByNetwork {
                        self.placeholderView.state = .failed
                    } else {
                        self.placeholderView.state = .completed
                    }
                    if error.code != 403 {
                        // 接口貌似不稳定 http code 403贼多
                        SwiftyHUD.show(message: error.message)
                    }
                }
            }.disposed(by: disposeBag)
    }
}

extension AudioSearchViewController {
    /// 加载缓存
    private func loadKeywordsCache() {
        placeholderView.state = .loading
        let keywords = KeywordsCache.restore()
//        let keywords = ["Fate Stay Night", "邓紫棋", "Nevada", "刘珂矣", "徒然喜欢你", "某科学的超电磁炮主题曲", "MO1", "空之境界", "Point Zero"]
        viewModel.inputs.loadKeywordsCache(keywords)
    }
    
    /// 搜索音频相关资源
    private func searchAudioRelative(by keyword: String, allowsCache: Bool = false) {
        if allowsCache {
            KeywordsCache.store(keyword)
        }
        placeholderView.state = .loading
        viewModel.inputs.searchAudioRelative(by: keyword)
    }
    
    /// 上拉加载
    @objc private func pullToRefresh() {
        guard let keyword = searchBar.text else {
            return
        }
        viewModel.inputs.pullToRefesh(by: keyword)
    }
}

extension AudioSearchViewController: FDPlaceholderViewDelegate {
    func placeholderViewWillBeginRetry(_ placeholderView: FDPlaceholderView) {
        let keyword = searchBar.text.filterNil()
        searchAudioRelative(by: keyword)
    }
}

extension AudioSearchViewController: AudioSearchHeaderViewDelegate {
    func audioSearchHeaderViewWillClearSearchHistory(_ headerView: AudioSearchHeaderView) {
        KeywordsCache.removeAll()
        loadKeywordsCache()
    }
}

extension AudioSearchViewController: AudioSearchHistoryCellDelegate {
    func historyCell(_ cell: AudioSearchHistoryCell, willTriggerSearchAt keyword: String) {
        searchBar.text = keyword
        searchBar.sendActions(for: .allEditingEvents)
        KeywordsCache.store(keyword) // 调整顺序
    }
}

extension AudioSearchViewController: AudioSearchResultCellDelegate {
    func searchResultCell(_ cell: AudioSearchResultCell, willChangeLikeStatus isLike: Bool) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        guard let audio = dataSource[indexPath] as? MusicInfo else { return }
        viewModel.inputs.mutateLikeStatus(audio, at: indexPath)
    }
    
    func searchResultCellWillOpenPopupMenu(_ cell: AudioSearchResultCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }
        guard let audio = dataSource[indexPath] as? MusicInfo else {
            return
        }
        let menu = AudioPopupMenu()
        menu.width = view.width
        menu.delegate = self
        menu.height = 220
        if #available(iOS 11.0, *) {
            menu.height += view.safeAreaInsets.bottom
        }
        menu.configureWith(value: audio)
        FDPopupViewBuilder()
            .setSourceView(view)
            .setContentView(menu)
            .setStyle(.translucent(alpha: 0.4))
            .setPresentationStyle(.bottom)
            .setPresentationAnimation(.fromBottom)
            .setDismissalAimation(.fromBottom)
            .build().popup()
    }
}

extension AudioSearchViewController: AudioPopupMenuDelegate {
    func popupMenuWillPlayNext(_ menu: AudioPopupMenu) {
        streamer.playNext()
    }
    
    func popupMenu(_ menu: AudioPopupMenu, willAddAudioToPlayList audio: MusicInfo) {
        if streamer.currentAudioList?.contains(where: { $0.isEqual(audio) }) ?? false {
            SwiftyHUD.show(message: "歌曲已存在")
        } else {
            streamer.appendAudioList([audio])
            SwiftyHUD.show(message: "歌曲已添加")
        }
    }
    
    func popupMenu(_ menu: AudioPopupMenu, willDownloadAudio audio: MusicInfo) {
        
    }
}

extension AudioSearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard curSection == .result else { return }
        guard let audio = dataSource[indexPath] as? MusicInfo else { return }
        KeywordsCache.store(audio.fd.highlightedKey) // 存储关键词
        streamer.appendAudioList([audio])
        streamer.play(audio: audio)
        let vc = AudioPlayerViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? AudioSearchHistoryCell, cell.delegate == nil {
            cell.delegate = self
        } else if let cell = cell as? AudioSearchResultCell, cell.delegate == nil {
            cell.delegate = self
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        // 历史记录才需要
        if curSection == .history {
            let view = AudioSearchHeaderView()
            view.delegate = self
            return view
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return curSection == .history ? 32 : 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if curSection == .history {
            return tableView.fd.heightForRowAt(indexPath, cellClass: AudioSearchHistoryCell.self, configuration: { (cell) in
                guard let value = self.dataSource[indexPath] as? [String] else { return }
                cell.configureWith(value: value)
            })
        }
        return 58
    }
}

extension AudioSearchViewController {
    @objc private func popViewController() {
        navigationController?.popViewController(animated: false)
    }
}

extension AudioSearchViewController {
    private func buildNavbar() {
        searchBar.placeholderText = "搜索音乐、歌手"
        fd.navigationItem.titleView = searchBar
        fd.navigationBar.contentMargin.left = 10
        fd.navigationItem.leftBarButtonItem = nil
        fd.navigationItem.titleViewMargin.right = 9
        fd.navigationItem.rightBarButtonItem = FDBarButtonItem(title: "取消", target: self,
                                                               action: #selector(popViewController))
        let titleTextAttributes: [NSAttributedString.Key : Any] = [.font : UIFont.systemFont(ofSize: 15),
                                                                   .foregroundColor : GLarkdef.gray_B1B2BF]
        fd.navigationItem.rightBarButtonItem?.setTitleTextAttributes(titleTextAttributes, for: .normal)
        fd.navigationItem.rightBarButtonItem?.setTitleTextAttributes(titleTextAttributes, for: .highlighted)
    }
    
    private func buildUI() {
        automaticallyAdjustsScrollViewInsets = false
        view.backgroundColor = .white
        
        curSection = .history // 避免进来闪烁
        
        tableView.delegate = self
        tableView.dataSource = dataSource
        dataSource.registerClasses(tableView: tableView)
        tableView.refreshFooter.setRefreshingTarget(self,
                                refreshingAction: #selector(pullToRefresh))
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(fd.navigationBar.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
        
        view.addSubview(placeholderView)
        placeholderView.snp.makeConstraints { (make) in
            make.edges.equalTo(tableView)
        }
    }
}
