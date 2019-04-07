//
//  AudioBoxViewController.swift
//  AppMusic
//
//  Created by Archer on 2019/2/25.
//

import Fate
import Fatal
import RxMoya
import FOLDin
import RxSwift
import RxCocoa
import SwiftyHUD
import RxSwiftExt
import AudioService

class AudioBoxViewController: UIViewController {
    
    override var prefersNavigationBarStyle: UINavigationBarStyle {
        return .custom
    }
    
    private lazy var searchBar = GLarkPlaceholderBar()
    private lazy var bannerView = GLarkBannerView()
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 0
        let v = UICollectionView(frame: .zero, collectionViewLayout: layout)
        v.backgroundColor = .white
        if #available(iOS 11, *) {
            v.contentInsetAdjustmentBehavior = .never
        }
        return v
    }()
    private lazy var beginOffsetY: CGFloat = 0
    private lazy var flowView: AudioFlowView? = AudioFlowView()
    
    private var streamer = AudioStreamerBuilder().build()
    
    private let dataSource = AudioBoxDataSource()
    private let viewModel: AudioBoxViewModelType = AudioBoxViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        buildUI()
        buildNavbar()
        performBinding()
        beginRefreshing()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        prepareStreamer()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        cleanStreamer()
    }
    
    private func prepareStreamer() {
        streamer.delegate = self
        flowView?.reloadData()
    }
    
    private func cleanStreamer() {
        streamer.delegate = nil
    }
    
    deinit {
        NSLog("%@ is deallocating...", className())
    }
}

// MARK: 事件绑定

extension AudioBoxViewController {
    private func performBinding() {

        // 去音乐搜索
        viewModel.outputs.goAudioSearch
            .subscribeNext(weak: self) { (self)  in
                return { (placeholderText) in
                    let vc = AudioSearchViewController()
                    self.navigationController?.pushViewController(vc, animated: false)
                }
            }.disposed(by: disposeBag)
        
        // 下拉刷新
        collectionView.refreshHeader.rx.refresh
            .debounce(1, scheduler: MainScheduler.instance)
            .filter { $0 == .refreshing }
            .subscribeNext(weak: self) { (self) in
                return { _ in
                    self.beginRefreshing()
                }
            }.disposed(by: disposeBag)
        
        // 加载了banner
        viewModel.outputs.bannerLoaded
            .subscribeNext(weak: self) { (self) in
                return { (resps) in
                    self.bannerView.configureWith(value: resps)
                }
            }.disposed(by: disposeBag)
        
        // 加载了歌单
        viewModel.outputs.audioSheetLoaded
            .subscribeNext(weak: self) { (self) in
                return { (resps) in
                    self.dataSource.load(audioSheetList: resps)
                    self.collectionView.reloadData()
                }
            }.disposed(by: disposeBag)
        
        // 点击cell去歌单列表
        viewModel.outputs.goAudioSheet
            .subscribeNext(weak: self) { (self) in
                return { (sheet) in
                    let vc = AudioSheetListViewController()
                    vc.audioSheet = sheet
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }.disposed(by: disposeBag)
        
        // 更新刷新状态
        viewModel.outputs.refreshState
            .bind(to: collectionView.refreshHeader.rx.refresh)
            .disposed(by: disposeBag)
        
        // 处理失败
        viewModel.outputs.showError
            .subscribeNext(weak: self) { (self) in
                return { (error) in
                    SwiftyHUD.show(message: error.message)
                }
            }.disposed(by: disposeBag)
    }
}

// MARK: 其他事件

extension AudioBoxViewController {
    /// 跳转搜索
    @objc private func goAudioSearch() {
        viewModel.inputs.searchBarTapped(searchBar.placeholderText)
    }
    
    /// 下拉刷新
    @objc private func beginRefreshing() {
        viewModel.inputs.beginRefreshing()
    }
}

// MARK: UICollectionViewDelegateFlowLayout

extension AudioBoxViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let value = dataSource[indexPath]
        if let sheet = value as? MusicSheetInfo {
            viewModel.inputs.tappedAudioSheet(sheet)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let imageWidth = view.width - 20
        return CGSize(width: imageWidth, height: 250)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.width, height: 45)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 7.5, bottom: 0, right: 7.5)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        beginOffsetY = scrollView.contentOffset.y
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let flowView = flowView else { return }
        let offsetY = scrollView.contentOffset.y
        if offsetY - beginOffsetY > 50 { // 向下
            if flowView.top != view.bottom {
                flowView.snp.updateConstraints { (make) in
                    make.bottom.equalTo(45)
                }
                UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut, animations: {
                    self.view.layoutIfNeeded()
                }, completion: nil)
            }
        } else if beginOffsetY - offsetY > 50 {
            if flowView.bottom != (view.bottom - 8) {
                flowView.snp.updateConstraints { (make) in
                    make.bottom.equalTo(-20)
                }
                UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseIn, animations: {
                    self.view.layoutIfNeeded()
                }, completion: nil)
            }
        }
    }
}

// MARK: GLarkBannerViewDelegate

extension AudioBoxViewController: GLarkBannerViewDelegate {
    func bannerViewDidTapped(at audioSheet: MusicSheetInfo) {
        viewModel.inputs.tappedAudioSheet(audioSheet)
    }
}

extension AudioBoxViewController: AudioFlowViewDelegate, AudioFlowViewDataSource {
    func audioFlowView(_ flowView: AudioFlowView, willChangePlayStatus isPlaying: Bool) {
        if isPlaying {
            if streamer.isAudioListEmpty {
                SwiftyHUD.show(message: "你还没有选歌")
                flowView.reloadData()
            } else {
                streamer.resume()
            }
        } else {
            streamer.pause()
        }
    }
    
    func audioFlowViewWillClose(_ flowView: AudioFlowView) { // 暂时去掉
        flowView.removeFromSuperview()
        self.flowView = nil
    }
    
    func audioFlowViewWillOpenPlayerController(_ flowView: AudioFlowView) {
        guard !streamer.isAudioListEmpty else {
            SwiftyHUD.show(message: "你还没有选歌")
            return
        }
        let vc = AudioPlayerViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func currentAudioForFlowView(_ flowView: AudioFlowView) -> MusicInfo? {
        return streamer.currentAudio
    }
    
    func playStatusForFlowView(_ flowView: AudioFlowView) -> AudioStreamerPlayStatus {
        return streamer.playStatus
    }
}

extension AudioBoxViewController: AudioStreamerDelegate {
    func audioStramerPlayStatusDidChange(_ newStatus: AudioStreamerPlayStatus) {
        flowView?.reloadPlayStatus()
    }
    
    func audioStreamerCurrentAudioDidChange(_ newAudio: MusicInfo) {
        flowView?.reloadAudio()
    }
    
    func audioStreamerDidFinishWithError(_ error: ErrorConvertible) {
        SwiftyHUD.show(message: error.message)
    }
    
    func audioStreamerPlayModeDidChange(_ newMode: AudioStreamerPlayMode) { }
        
    func audioStreamerCurrentTimeDidChange(_ currentTime: Double) { }
    
    func audioStreamerBufferedTimeDidChange(_ bufferedTime: Double) { }
}

// MARK: 布局

extension AudioBoxViewController {
    private func buildNavbar() {
        searchBar.placeholderText = "搜点什么吧"
        searchBar.size = CGSize(width: kScreenWidth - 20, height: 30)
        searchBar.addTarget(self, action: #selector(goAudioSearch), for: .touchUpInside)
        fd.navigationItem.titleView = searchBar
        fd.navigationBar.contentMargin = FDMargin(left: 10, right: 10)
    }
    
    private func buildUI() {
        automaticallyAdjustsScrollViewInsets = false
        view.backgroundColor = .white

        bannerView.left = 0
        bannerView.height = 200
        bannerView.width = view.width
        bannerView.top = -bannerView.height
        bannerView.delegate = self
        collectionView.insertSubview(bannerView, at: Int.max)

        collectionView.delegate = self
        collectionView.dataSource = dataSource
        dataSource.registerClasses(collectionView: collectionView)
        collectionView.contentInset = UIEdgeInsets(top: bannerView.height,
                                                   left: 0, bottom: 20, right: 0)
        collectionView.refreshHeader.ignoredScrollViewContentInsetTop = bannerView.height
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { (make) in
            make.top.equalTo(fd.navigationBar.snp.bottom)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        flowView?.delegate = self
        flowView?.dataSource = self
        view.addSubview(flowView!)
        flowView?.snp.makeConstraints { (make) in
            make.bottom.equalTo(45)
            make.left.equalTo(10)
            make.right.equalTo(-10)
            make.height.equalTo(45)
        }
    }
}
