//
//  AudioSheetListViewController.swift
//  AppMusic
//
//  Created by Archer on 2019/2/25.
//

import Fate
import Fatal
import YYKit
import FOLDin
import RxSwift
import SwiftyHUD
import SkeletonView
import AudioService

/// 歌单列表
class AudioSheetListViewController: UIViewController {

    override var prefersNavigationBarStyle: UINavigationBarStyle {
        return .custom
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    /// 传递来的参数
    var audioSheet: MusicSheetInfo?
    
    private lazy var scaleImageView: UIImageView = {
        let v = UIImageView()
        v.clipsToBounds = true
        v.contentMode = .scaleAspectFill
        return v
    }()
    
    private lazy var toolBar = AudioSheetToolBar()
    
    private lazy var tableView: UITableView = {
        let v = UITableView(frame: .zero, style: .plain)
        v.rowHeight = 58
        v.estimatedRowHeight = 58
        v.backgroundColor = .clear
        v.tableFooterView = UIView()
        v.separatorStyle = .singleLine
        v.separatorColor = GLarkdef.gray_EAEAEA
        v.separatorInset = UIEdgeInsets(top: 0, left: 45, bottom: 0, right: 0)
        if #available(iOS 11, *) {
            v.contentInsetAdjustmentBehavior = .never
        }
        return v
    }()
    
    private lazy var tableHeaderView = AudioSheetListHeaderView()
    
    private lazy var placeholderView = FDPlaceholderView()

    private let dataSource = AudioSheetListDataSource()
    private let viewModel: AudioSheetListViewModelType = AudioSheetListViewModel()
    
    private lazy var streamer = AudioStreamerBuilder().build()
    
    private lazy var offset = 0 // 当前位置
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buildUI()
        buildNavbar()
        performBinding()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        prepareStreamer()
        reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        fetchAudioList()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        cleanStreamer()
    }

    deinit {
        NSLog("%@ is deallocating...", className())
    }
}

extension AudioSheetListViewController {
    private func performBinding() {
        
        // 处理返回的歌曲
        viewModel.outputs.audioList
            .subscribeNext(weak: self) { (self) in
                return { (audios) in
                    guard let audioSheet = self.audioSheet else { return }
                    self.tableHeaderView.configureWith(value: audioSheet)
                    self.dataSource.load(audioList: audios)
                    self.reloadData()
                    // NOTE: reload data first
                    self.view.hideSkeleton()
                    self.tableHeaderView.hideSkeleton()
                    self.placeholderView.state = audios.isEmpty ? .empty : .completed
                }
            }.disposed(by: disposeBag)
        
        /// 上拉加载更多
        tableView.refreshFooter.rx.refresh
            .debounce(1, scheduler: MainScheduler.instance)
            .filter { $0 == .refreshing }
            .subscribeNext(weak: self) { (self) in
                return { _ in
                    guard let type = self.audioSheet?.type else { return }
                    self.offset += self.dataSource.numberOfItems()
                    self.viewModel.inputs.pullToRefresh(by: type, offset: self.offset)
                }
            }.disposed(by: disposeBag)
        
        // 处理上拉数据返回
        viewModel.outputs.audioListAppended
            .subscribeNext(weak: self) { (self) in
                return { (audios) in
                    let indexPaths = self.dataSource.append(audioList: audios)
                    self.tableView.insertRows(at: indexPaths, with: .none)
                    self.view.hideSkeleton()
                    self.tableHeaderView.hideSkeleton()
                    self.placeholderView.state = self.dataSource.numberOfItems() == 0 ? .empty : .completed
                }
            }.disposed(by: disposeBag)
        
        // 更新刷新控件状态
        viewModel.outputs.pullToRefreshState
            .bind(to: tableView.refreshFooter.rx.refresh)
            .disposed(by: disposeBag)
        
        // 处理喜欢
        viewModel.outputs.likeStatus
            .subscribeNext(weak: self) { (self) in
                return { (result) in
                    let flag = result.flag
                    let indexPath = result.indexPath
                    self.dataSource.load(flag: flag, at: indexPath)
                    self.tableView.reloadRow(at: indexPath, with: .none)
                }
            }.disposed(by: disposeBag)
        
        // 处理失败
        viewModel.outputs.showError
            .subscribeNext(weak: self) { (self) in
                return { (error) in
                    self.view.hideSkeleton()
                    self.tableHeaderView.hideSkeleton()
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

extension AudioSheetListViewController {
    /// 加载歌曲
    private func fetchAudioList() {
        guard let sheet = audioSheet else { return }
        if dataSource.numberOfItems() == 0 {
            view.showAnimatedSkeleton()
            tableHeaderView.showAnimatedSkeleton()
            viewModel.inputs.fetchAudioList(by: sheet.type)
        }
    }
    
    private func prepareStreamer() {
        streamer.delegate = self
        toolBar.reloadData()
    }
    
    private func cleanStreamer() {
        streamer.delegate = nil
    }

    private func reloadData() {
        // 遍历一下看是否需要高亮
        if dataSource.numberOfItems() != 0 {
            guard let audioList = dataSource[section: 0]
                as? [MusicInfo] else {
                    return
            }
            let curAudio = streamer.currentAudio
            for audio in audioList {
                let isPlaying = audio.isEqual(curAudio)
                if audio.fd.isPlaying && isPlaying {
                    return
                }
                audio.fd.isPlaying = isPlaying
            }
            tableView.reloadData()
        }
    }
}

extension AudioSheetListViewController: FDPlaceholderViewDelegate {
    func placeholderViewWillBeginRetry(_ placeholderView: FDPlaceholderView) {
        fetchAudioList()
    }
}

extension AudioSheetListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? AudioSheetListCell, cell.delegate == nil {
            cell.delegate = self
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard !tableView.isSkeletonActive else { return }
        guard let audio = dataSource[indexPath] as? MusicInfo else { return }
        if !audio.isEqual(streamer.currentAudio) {
            guard let audioList = dataSource[section: indexPath.section] as? [MusicInfo] else { return }
            streamer.playAtIndex(indexPath.row, audioList: audioList)
        }
        let vc = AudioPlayerViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard dataSource.numberOfItems() != 0 else { return nil }
        guard let audios = dataSource[section: section] as? [MusicInfo] else { return nil }
        let headerView = AudioSheetListSectionHeaderView()
        headerView.configureWith(value: audios)
        headerView.delegate = self
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let audioSheet = audioSheet else { return }
        let navbarHeight = fd.fullNavbarHeight
        let headerViewHeight = tableHeaderView.height
        let imageViewHeight = navbarHeight + headerViewHeight
        let offsetY = scrollView.contentOffset.y
        // 下拉放大
        if offsetY <= 0 {
            scaleImageView.height = imageViewHeight + abs(offsetY)
        } else {
            scaleImageView.height = max(navbarHeight, imageViewHeight - offsetY)
        }
        // 修改标题
        let titleLabelFrame = tableHeaderView.titleLabelFrame
        var convertedFrame = view.convert(titleLabelFrame, from: tableHeaderView)
        convertedFrame.origin.y -= navbarHeight
        let isVisible = view.bounds.intersects(convertedFrame)
        fd.navigationItem.title = isVisible ? "歌单" : audioSheet.title
    }
}

extension AudioSheetListViewController: AudioSheetListCellDelegate {
    func sheetListCell(_ cell: AudioSheetListCell, willChangeLikeStatus isLike: Bool) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        guard let audio = dataSource[indexPath] as? MusicInfo else { return }
        viewModel.inputs.mutateLikeStatus(audio, at: indexPath)
    }
    
    func sheetListCellWillOpenPopupMenu(_ cell: AudioSheetListCell) {
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

extension AudioSheetListViewController: AudioSheetListSectionHeaderViewDelegate {
    func audioStramerWillPlayWholeSheet() {
        if dataSource.numberOfItems() != 0 {
            guard let audioList = dataSource[section: 0] as? [MusicInfo] else { return }
            let index = Int(arc4random_uniform(UInt32(audioList.count)))
            streamer.playAtIndex(index, audioList: audioList)
            let vc = AudioPlayerViewController()
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension AudioSheetListViewController: AudioPopupMenuDelegate {
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

extension AudioSheetListViewController: AudioSheetToolBarDataSource {
    func currentAudioForToolBar(_ toolBar: AudioSheetToolBar) -> MusicInfo? {
        return streamer.currentAudio
    }
    
    func playStatusForToolBar(_ toolBar: AudioSheetToolBar) -> AudioStreamerPlayStatus {
        return streamer.playStatus
    }
}

extension AudioSheetListViewController: AudioSheetToolBarDelegate {
    func audioStreamerWillChangeState(_ isPlaying: Bool) {
        if isPlaying {
            if streamer.isAudioListEmpty {
                SwiftyHUD.show(message: "你还没有选歌")
                toolBar.reloadData()
            } else {
                streamer.resume()
            }
        } else {
            streamer.pause()
        }
    }
    
    func audioStreamerWillShowAudioList() {
        guard !streamer.isAudioListEmpty else {
            SwiftyHUD.show(message: "你还没有选歌")
            return
        }
        let listView = AudioPopupView()
        listView.delegate = self
        listView.dataSource = self
        listView.width = view.width
        listView.height = view.height * 0.667
        FDPopupViewBuilder()
            .setSourceView(view)
            .setContentView(listView)
            .setPresentationStyle(.bottom)
            .setPresentationAnimation(.fromBottom)
            .setDismissalAimation(.fromBottom)
            .setStyle(.translucent(alpha: 0.4))
            .build().popup()
    }
    
    func audioStreamerWillOpenPlayerController() {
        guard !streamer.isAudioListEmpty else {
            SwiftyHUD.show(message: "你还没有选歌")
            return
        }
        let vc = AudioPlayerViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension AudioSheetListViewController: AudioPopupViewDelegate, AudioPopupViewDataSource {
    func popupView(_ popupView: AudioPopupView, didSelectAudioAtIndex index: Int) {
        streamer.play(at: index)
    }
    
    func popupViewWillRemoveAudio(at index: Int) {
        guard let audioList = streamer.currentAudioList else {
            return
        }
        streamer.removeAudioList([audioList[index]])
        toolBar.reloadData()
    }
    
    func popupViewWillChangePlayMode(_ popupView: AudioPopupView) {
        let playMode = streamer.playMode
        streamer.playMode = playMode.next
    }
    
    func popupViewWillClearPlayList(_ popupView: AudioPopupView) {
        guard let audioList = streamer.currentAudioList else {
            SwiftyHUD.show(message: "你还没有选歌")
            return
        }
        streamer.removeAudioList(audioList)
        toolBar.reloadData()
    }
    
    func playModeForPopupView(_ popupView: AudioPopupView) -> AudioStreamerPlayMode {
        return streamer.playMode
    }
    
    func playListForPopupView(_ popupView: AudioPopupView) -> [MusicInfo]? {
        return streamer.currentAudioList
    }
    
    func currentPlayIndexForPopupView(_ popupView: AudioPopupView) -> Int? {
        return streamer.currentIndex
    }
}

extension AudioSheetListViewController: AudioStreamerDelegate {
    func audioStramerPlayStatusDidChange(_ newStatus: AudioStreamerPlayStatus) {
        toolBar.reloadPlayStatus()
    }
    
    func audioStreamerCurrentAudioDidChange(_ newAudio: MusicInfo) {
        reloadData() // it's needed
        toolBar.reloadAudio()
    }
    
    func audioStreamerDidFinishWithError(_ error: ErrorConvertible) {
        SwiftyHUD.show(message: error.message)
    }
    
    func audioStreamerPlayModeDidChange(_ newMode: AudioStreamerPlayMode) { }
    
    func audioStreamerCurrentTimeDidChange(_ currentTime: Double) { }
    
    func audioStreamerBufferedTimeDidChange(_ bufferedTime: Double) { }
}

extension AudioSheetListViewController {
    /// 返回上一级
    @objc private func popViewControllerAnimated() {
        navigationController?.popViewController(animated: true)
    }
}

extension AudioSheetListViewController {
    private func buildNavbar() {
        fd.navigationItem.title = "歌单"
        fd.navigationBar.barTintColor = .clear
        fd.navigationBar.titleTextAttributes = [.foregroundColor : UIColor.white,
                                                .font : UIFont.boldSystemFont(ofSize: 17)]
        fd.navigationBar.contentMargin.left = 5
        let backButton = UIButton()
        let image = UIImage(nameInBundle: "nav_back_white")?
            .byResize(to: CGSize(width: 30, height: 30), contentMode: .center)
        backButton.setImage(image, for: .normal)
        backButton.size = CGSize(width: 30, height: 30)
        backButton.addTarget(self, action: #selector(popViewControllerAnimated), for: .touchUpInside)
        fd.navigationItem.leftBarButtonItem = FDBarButtonItem(customView: backButton)
    }
    
    private func buildUI() {
        automaticallyAdjustsScrollViewInsets = false
        view.backgroundColor = .white
        view.isSkeletonable = true
        
        toolBar.delegate = self
        toolBar.dataSource = self
        view.addSubview(toolBar)
        toolBar.snp.makeConstraints { (make) in
            if #available(iOS 11.0, *) {
                make.top.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-55)
            } else {
                make.height.equalTo(55)
            }
            make.bottom.equalToSuperview()
            make.left.right.equalToSuperview()
        }
        
        tableHeaderView.height = 165
        tableHeaderView.width = view.width
        tableView.tableHeaderView = tableHeaderView
        
        scaleImageView.origin = .zero
        scaleImageView.width = view.width
        scaleImageView.height = fd.fullNavbarHeight + tableHeaderView.height
        view.addSubview(scaleImageView)
        scaleImageView.setImageWith(URL(string: (audioSheet?.imgUrl).filterNil()),
                                    placeholder: nil, options: [.avoidSetImage])
        { [weak self] (image, _, _, _, _) in
            guard let `self` = self else { return }
            let transition = CATransition()
            transition.type = .fade
            transition.duration = 0.2
            transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            self.scaleImageView.layer.add(transition, forKey: "_KFadeAnimationKey")
            self.scaleImageView.image = image?.byBlurRadius(35,
                                               tintColor: UIColor(white: 1, alpha: 0.1),
                                               tintMode: .normal, saturation: 1.8, maskImage: nil)
        }

        tableView.isSkeletonable = true
        tableView.delegate = self
        tableView.dataSource = dataSource
        dataSource.registerClasses(tableView: tableView)
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(fd.navigationBar.snp.bottom)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(toolBar.snp.top)
        }
        
        placeholderView.delegate = self
        view.addSubview(placeholderView)
        placeholderView.snp.makeConstraints { (make) in
            make.bottom.equalTo(toolBar.snp.top)
            make.left.right.equalToSuperview()
            make.top.equalTo(tableView)
        }
        
        view.bringSubviewToFront(toolBar)
    }
}
