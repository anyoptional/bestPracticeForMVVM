//
//  AudioSheetListViewModel.swift
//  AppMusic
//
//  Created by Archer on 2019/2/25.
//

import Moya
import Fatal
import RxMoya
import RxSwift
import MJRefresh
import RxSwiftExt
import RxOptional
import AudioService

protocol AudioSheetListViewModelInputs {
    /// 加载歌曲列表
    func fetchAudioList(by type: Int)
    
    /// 上拉加载更多
    func pullToRefresh(by type: Int, offset: Int)
    
    /// 修改喜欢状态
    func mutateLikeStatus(_ audio: MusicInfo, at indexPath: IndexPath)
}

protocol AudioSheetListViewModelOutputs {
    /// 返回的歌曲
    var audioList: Observable<[MusicInfo]> { get }
    
    /// 上拉加载返回的歌曲
    var audioListAppended: Observable<[MusicInfo]> { get }
    
    /// 刷新控件的状态
    var pullToRefreshState: Observable<MJRefreshState> { get }

    /// 修改喜欢的结果
    var likeStatus: Observable<(flag: Bool, indexPath: IndexPath)> { get }
    
    /// 遭遇错误
    var showError: Observable<ErrorConvertible> { get }
}

protocol AudioSheetListViewModelType {
    var inputs: AudioSheetListViewModelInputs { get }
    var outputs: AudioSheetListViewModelOutputs { get }
}

class AudioSheetListViewModel: AudioSheetListViewModelType
    , AudioSheetListViewModelInputs
    , AudioSheetListViewModelOutputs {
    
    let disposeBag = DisposeBag()
    
    init() {
        
        let fetch = fetchRelay
            .flatMap { AudioProvider.fetchAndConvertAudioList(by: $0).materialize() }
            .share()
        
        audioList = fetch.elements()
        
        let refresh = refreshRelay
            .flatMap { AudioProvider.fetchAndConvertAudioList(by: $0.type, offset: $0.offset).materialize() }
            .share()
        
        audioListAppended = refresh.elements().share()
        
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
        
        
        showError = Observable.merge(fetch.errors(),
                                     refresh.errors(),
                                     likeReq.errors())
            .map { $0 as? ErrorConvertible }
            .filterNil()
        
        pullToRefreshState = .merge(showError.map { _ in .idle },
                                    audioListAppended.map { (audios) in
                                        if audios.isEmpty {
                                            return .noMoreData
                                        }
                                        return .idle
        })
    }
    
    fileprivate let fetchRelay = PublishSubject<Int>()
    func fetchAudioList(by type: Int) {
        fetchRelay.onNext(type)
    }
    
    fileprivate let refreshRelay = PublishSubject<(type: Int, offset: Int)>()
    func pullToRefresh(by type: Int, offset: Int) {
        refreshRelay.onNext((type: type, offset: offset))
    }
    
    fileprivate let mutateRelay = PublishSubject<(audio: MusicInfo, indexPath: IndexPath)>()
    func mutateLikeStatus(_ audio: MusicInfo, at indexPath: IndexPath) {
        mutateRelay.onNext((audio: audio, indexPath: indexPath))
    }
    
    var inputs: AudioSheetListViewModelInputs {
        return self
    }
    
    var outputs: AudioSheetListViewModelOutputs {
        return self
    }
    
    let likeStatus: Observable<(flag: Bool, indexPath: IndexPath)>
    let audioList: Observable<[MusicInfo]>
    let audioListAppended: Observable<[MusicInfo]>
    let showError: Observable<ErrorConvertible>
    let pullToRefreshState: Observable<MJRefreshState>
}

extension AudioProvider {
    /// 大体的播放结构是以前就写定了的
    /// but百度返回的榜单信息里边，歌曲的播放地址要另外查
    /// 这里不想去改这个播放结构了，所以这里在查询榜单信息的时候
    /// 顺便查了一下歌曲播放地址，然后组合了一下 算是偷个懒吧
    static func fetchAndConvertAudioList(by type: Int, offset: Int = 0) -> Observable<[MusicInfo]> {
        return AudioProvider.fetchAudioList(by: type, offset: offset)
            .mapObject(AudioListResp.self)
            .map { (resp) -> [AudioListResp.Song_listBean]? in
                if (resp.billboard?.havemore ?? 0) != 0 {
                    return resp.song_list
                }
                return nil
            }.flatMap { (songs) -> Observable<[MusicInfo]> in
            if let ids = songs?.map({ $0.song_id }), ids.isNotEmpty {
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
