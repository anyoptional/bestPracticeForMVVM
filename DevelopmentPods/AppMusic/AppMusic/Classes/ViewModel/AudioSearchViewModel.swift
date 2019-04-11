//
//  AudioSearchViewModel.swift
//  AppMusic
//
//  Created by Archer on 2019/2/25.
//

import Fatal
import RxMoya
import FOLDin
import RxSwift
import MJRefresh
import RxOptional
import AudioService

protocol AudioSearchViewModelInput {
    /// 加载缓存关键字
    func loadKeywordsCache(_ keywords: [String])
    /// 关键字搜索
    func searchAudioRelative(by keyword: String)
    /// 加载更多
    func pullToRefesh(by keyword: String)
    /// 修改喜欢状态
    func mutateLikeStatus(_ audio: MusicInfo, at indexPath: IndexPath)
}

protocol AudioSearchViewModelOutput {
    /// 加载了缓存关键字
    var cacheLoaded: Observable<[String]> { get }
    /// 加载了音频
    var audioLoaded: Observable<[MusicInfo]> { get }
    /// 加载了更多音频
    var audioAppended: Observable<[MusicInfo]> { get }
    /// 错误
    var showError: Observable<ErrorConvertible> { get }
    /// 上拉状态
    var pullToRefreshState: Observable<MJRefreshState> { get }
    /// 修改喜欢的结果
    var likeStatus: Observable<(flag: Bool, indexPath: IndexPath)> { get }
}

protocol AudioSearchViewModelType {
    var inputs: AudioSearchViewModelInput { get }
    var outputs: AudioSearchViewModelOutput { get }
}

class AudioSearchViewModel: AudioSearchViewModelType
    , AudioSearchViewModelInput
    , AudioSearchViewModelOutput {
    
    init() {
        
        cacheLoaded = cacheRelay.asObservable()
        
        let searchReq = searchRelay
            .flatMap { AudioProvider.searchAndConvertAudioList(by: $0,
                                                           page: curPage)
                .materialize()
            }
            .share()
        
        audioLoaded = searchReq.elements()
            .do(onNext: { (audios) in
                audios.forEach { $0.fd.highlightedKey = highlightedKey }
            }).share()
        
        let refreshReq = pullToRefeshRelay
            .flatMap { AudioProvider.searchAndConvertAudioList(by: $0, page: curPage).materialize() }
            .share()
        
        audioAppended = refreshReq.elements()
            .do(onNext: { (audios) in
                audios.forEach { $0.fd.highlightedKey = highlightedKey }
            }).share()
        
        let indexPath = mutateRelay.map { $0.indexPath }
        let likeReq = mutateRelay
            .map { $0.audio }
            .flatMap { (audio) -> Observable<Event<Void>> in
                // 已经收藏了就取消
                if audio.isCollection {
                    return AudioProvider.cancelAudioCollection(by: [audio.musicId.filterNil()]).materialize()
                }
                // 否则就收藏
                return AudioProvider.addAudioCollection(by: [audio.musicId.filterNil()]).materialize() }
            .share()
        
        likeStatus = Observable.combineLatest(indexPath, likeReq) { (indexPath, event) in
            return (flag: event.element != nil, indexPath: indexPath)
        }
        
        showError = Observable.merge(searchReq.errors(),
                                     refreshReq.errors(),
                                     likeReq.errors())
            .map { $0 as? ErrorConvertible }
            .filterNil()
        
        pullToRefreshState = .merge(showError.map { _ in .idle },
                                    audioLoaded.map { _ in .idle },
                                    audioAppended.map {
                                        if $0.isEmpty {
                                            return .noMoreData
                                        }
                                        return .idle })
    }
    
    fileprivate let searchRelay = PublishSubject<String>()
    func searchAudioRelative(by keyword: String) {
        curPage = 1
        highlightedKey = keyword
        searchRelay.onNext(keyword)
    }
    
    fileprivate let cacheRelay = PublishSubject<[String]>()
    func loadKeywordsCache(_ keywords: [String]) {
        cacheRelay.onNext(keywords)
    }
    
    fileprivate let pullToRefeshRelay = PublishSubject<String>()
    func pullToRefesh(by keyword: String) {
        curPage += 1
        pullToRefeshRelay.onNext(keyword)
    }
    
    fileprivate let mutateRelay = PublishSubject<(audio: MusicInfo, indexPath: IndexPath)>()
    func mutateLikeStatus(_ audio: MusicInfo, at indexPath: IndexPath) {
        mutateRelay.onNext((audio: audio, indexPath: indexPath))
    }
    
    var inputs: AudioSearchViewModelInput {
        return self
    }
    
    var outputs: AudioSearchViewModelOutput {
        return self
    }
    
    let cacheLoaded: Observable<[String]>
    let audioLoaded: Observable<[MusicInfo]>
    let audioAppended: Observable<[MusicInfo]>
    let showError: Observable<ErrorConvertible>
    let pullToRefreshState: Observable<MJRefreshState>
    let likeStatus: Observable<(flag: Bool, indexPath: IndexPath)>
}

fileprivate var curPage = 1
fileprivate var highlightedKey = ""

extension AudioProvider {
    static func searchAndConvertAudioList(by keyword: String, page: Int = 0) -> Observable<[MusicInfo]> {
        
        return AudioProvider.searchAudios(by: keyword, page: page)
            .mapObject(AudioSearchResp.self)
            .map { $0.result?.song_info }
            .flatMap { (songs) -> Observable<[MusicInfo]> in
                if let songs = songs, songs.total > 0,
                    let ids = songs.song_list?.map({ $0.song_id }) {
                    var observables = [Observable<JSONObject>]()
                    for id in ids {
                        observables.append(AudioProvider.fetchAudioInfo(by: id))
                    }
                    // 403太多了 过滤掉
                    return Observable.merge(observables)
                        .mapObject(AudioInfoResp.self)
                        .map { $0.toMusicInfo() }
                        .filterNil()
                        .toArray()
                }
                return .just([])
        }
    }
}
