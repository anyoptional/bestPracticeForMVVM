//
//  AudioBoxViewModel.swift
//  AppMusic
//
//  Created by Archer on 2019/2/25.
//

import Fatal
import RxSwift
import MJRefresh
import RxOptional
import AudioService

protocol AudioBoxViewModelInputs {
    /// 下拉刷新
    func beginRefreshing()
    
    /// 搜索按钮点击
    func searchBarTapped(_ placeholderText: String?)
    
    /// 点击推荐cell
    func tappedAudioSheet(_ sheet: MusicSheetInfo)
}

protocol AudioBoxViewModelOutputs {
    /// 轮播图已加载
    var bannerLoaded: Observable<[MusicSheetInfo]> { get }
    
    /// 音乐推荐已加载
    var audioSheetLoaded: Observable<[MusicSheetInfo]> { get }
    
    /// 跳转音乐搜索
    var goAudioSearch: Observable<String?> { get }
    
    /// 错误
    var showError: Observable<ErrorConvertible> { get }
    
    /// 刷新控件状态
    var refreshState: Observable<MJRefreshState> { get }
    
    /// 去歌单列表
    var goAudioSheet: Observable<MusicSheetInfo> { get }
}

protocol AudioBoxViewModelType {
    var inputs: AudioBoxViewModelInputs { get }
    var outputs: AudioBoxViewModelOutputs { get }
}

class AudioBoxViewModel: AudioBoxViewModelType
    , AudioBoxViewModelInputs
, AudioBoxViewModelOutputs {
    
    init() {
        
        let refresh = refreshRelay
            .asObservable()
            .share()
        
        let bannerReq = refresh
            .flatMap {
                AudioProvider
                    .fetchAudioBanners()
                    .materialize()
            }.share()
        bannerLoaded = bannerReq.elements()
        

        let recommendReq = refresh
            .flatMap {
                AudioProvider
                    .fetchAudioSheets()
                    .materialize() }
            .share()
        audioSheetLoaded = recommendReq.elements()
        
        showError = Observable.merge(bannerReq.errors(),
                                     recommendReq.errors())
            .map { $0 as? ErrorConvertible }
            .filterNil()
        
        refreshState = .merge(showError.map { _ in .idle},
                              audioSheetLoaded.map { _ in .idle })
        
        goAudioSearch = searchRelay.asObservable()
        
        goAudioSheet = goAudioSheetRelay.asObservable()
    }
    
    var inputs: AudioBoxViewModelInputs {
        return self
    }
    
    var outputs: AudioBoxViewModelOutputs {
        return self
    }
    
    fileprivate let refreshRelay = PublishSubject<Void>()
    func beginRefreshing() {
        refreshRelay.onNext(Void())
    }
    
    fileprivate let searchRelay = PublishSubject<String?>()
    func searchBarTapped(_ placeholderText: String?) {
        searchRelay.onNext(placeholderText)
    }
    
    fileprivate let goAudioSheetRelay = PublishSubject<MusicSheetInfo>()
    func tappedAudioSheet(_ sheet: MusicSheetInfo) {
        goAudioSheetRelay.onNext(sheet)
    }
    
    let bannerLoaded: Observable<[MusicSheetInfo]>
    let audioSheetLoaded: Observable<[MusicSheetInfo]>
    let goAudioSearch: Observable<String?>
    let showError: Observable<ErrorConvertible>
    let refreshState: Observable<MJRefreshState>
    let goAudioSheet: Observable<MusicSheetInfo>
}
