//
//  AudioProvider.swift
//  AudioService
//
//  Created by Archer on 2019/3/24.
//

import Fatal
import RxMoya
import RxSwift
import AVFoundation

public struct AudioProvider {}

extension AudioProvider {
    /// 初始化
    public static func initialize() {
        if #available(iOS 10.0, *) {
            let session = AVAudioSession.sharedInstance()
            try? session.setCategory(.playAndRecord, mode: .default, options: [.allowBluetooth, .allowBluetoothA2DP])
            try? session.setActive(true, options: .notifyOthersOnDeactivation)
        }
    }
}

extension AudioProvider {
    /// 获取轮播信息
    public static func fetchAudioBanners() -> Observable<[MusicSheetInfo]> {
        let ballad = MusicSheetInfo()
        ballad.type = 23
        ballad.title = "情歌对唱榜"
        ballad.imgUrl = "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1554616722369&di=cdfdf3fc4c951c44e40b9d63cad0a2a9&imgtype=0&src=http%3A%2F%2Fi1.hdslb.com%2Fbfs%2Farchive%2F82fe4556b587af3350ff80d56bf803eac661d75f.jpg"
        
        let video = MusicSheetInfo()
        video.type = 24
        video.title = "影视金曲榜"
        video.imgUrl = "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1554618318731&di=88c00b69e53bd3435c89a1193aec0ab7&imgtype=0&src=http%3A%2F%2Fb-ssl.duitang.com%2Fuploads%2Fitem%2F201404%2F23%2F20140423102400_LQEFH.thumb.700_0.jpeg"
        
        let net = MusicSheetInfo()
        net.type = 25
        net.title = "网络歌曲"
        net.imgUrl = "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1554618360373&di=f921a927689004dacc3461b3329ede95&imgtype=0&src=http%3A%2F%2Fimg15.3lian.com%2F2015%2Ff2%2F63%2Fd%2F93.jpg"
        return .just([ballad, video, net])
    }
    
    /// 根据获取歌单信息
    public static func fetchAudioSheets() -> Observable<[MusicSheetInfo]> {
        let new = MusicSheetInfo()
        new.type = 1
        new.title = "新歌榜"
        new.imgUrl = "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1554613618957&di=e656635d6ab5cc37c9f94172d9ebb9e2&imgtype=0&src=http%3A%2F%2Fi0.hdslb.com%2Fbfs%2Farchive%2F48caf46076d4777b34f85bb9b405db3fb1b2e842.jpg"
        
        let hot = MusicSheetInfo()
        hot.type = 2
        hot.title = "热歌榜"
        hot.imgUrl = "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1554613758159&di=8e03d4d485f6dd7cb37b6fcb9bb6c049&imgtype=0&src=http%3A%2F%2Fi1.hdslb.com%2Fbfs%2Farchive%2Fe2d78e0c314825dc2f84af6710f8759fb03f31f6.jpg"
        
        let rock = MusicSheetInfo()
        rock.type = 11
        rock.title = "摇滚榜"
        rock.imgUrl = "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1554613854968&di=e6571d161282658e1e8b5d7e5ca3cc59&imgtype=0&src=http%3A%2F%2Fgss0.baidu.com%2F9fo3dSag_xI4khGko9WTAnF6hhy%2Fzhidao%2Fpic%2Fitem%2F3c6d55fbb2fb4316876d07e525a4462309f7d33b.jpg"

        let jazz = MusicSheetInfo()
        jazz.type = 12
        jazz.title = "爵士榜"
        jazz.imgUrl = "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1555208660&di=1e0525874f08f44ac91bd53deb9fc271&imgtype=jpg&er=1&src=http%3A%2F%2Fb-ssl.duitang.com%2Fuploads%2Fitem%2F201504%2F19%2F20150419H1540_5fAN2.thumb.700_0.png"
        
        let popular = MusicSheetInfo()
        popular.type = 16
        popular.title = "流行榜"
        popular.imgUrl = "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1554613986214&di=dae502717674a15db968cda11acef0cf&imgtype=0&src=http%3A%2F%2Fb-ssl.duitang.com%2Fuploads%2Fitem%2F201806%2F03%2F20180603210304_rdslz.thumb.700_0.jpg"
        
        let american = MusicSheetInfo()
        american.type = 21
        american.title = "欧美金曲榜"
        american.imgUrl = "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1554614148263&di=cc981f95adbf0eac735e0617f1f4c8a0&imgtype=0&src=http%3A%2F%2Fb-ssl.duitang.com%2Fuploads%2Fitem%2F201802%2F06%2F20180206195707_fucjz.thumb.700_0.png"
        
        
        let classic = MusicSheetInfo()
        classic.type = 22
        classic.title = "经典老歌榜"
        classic.imgUrl = "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1554614174937&di=a15a4b038ad7dc3176348f4790ad660f&imgtype=0&src=http%3A%2F%2Fb-ssl.duitang.com%2Fuploads%2Fitem%2F201709%2F20%2F20170920201543_aNEG4.jpeg"
        
        return .just([new, hot, rock, jazz, popular, american, classic])
    }
}

extension AudioProvider {
    /// 查询歌单下的歌曲
    /// 空数组表示没有更多数据
    public static func fetchAudioList(by type: Int, offset: Int = 0) -> Observable<JSONObject> {
        return APIProvider.rx.request(AudioAPI.fetchAudioList(type: type, offset: offset))
    }
    
    /// 根据id获取歌曲信息
    public static func fetchAudioInfo(by id: String?) -> Observable<JSONObject> {
        return APIProvider.rx.request(AudioAPI.fetchAudioInfo(songId: id))
    }
}

extension AudioProvider {
    /// 添加音乐收藏
    public static func addAudioCollection(by musicId: [String]) -> Observable<Void> {
        return .empty()

    }
    
    /// 取消音乐收藏
    public static func cancelAudioCollection(by musicId: [String]) -> Observable<Void> {
        return .empty()

    }
}

extension AudioProvider {
    /// 关键词搜索音乐id
    public static func searchSuggestByKeyword(by keyword: String) -> Observable<String> {
        return APIProvider.rx.request(AudioAPI.searchSuggestByKeyword(keyword: keyword))
    }
    
    /// 关键词搜索音乐id
    public static func searchAudios(by keyword: String, page: Int = 0) -> Observable<String> {
        return APIProvider.rx.request(AudioAPI.searchAudiosByKeyword(keyword: keyword, page: page))
    }
}
