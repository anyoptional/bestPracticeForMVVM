//
//  AudioAPI.swift
//  AudioService
//
//  Created by Archer on 2019/4/6.
//

import RxMoya

public enum AudioAPI {
    case fetchAudioList(type: Int, offset: Int)
    case fetchAudioInfo(songId: String?)
    case searchSuggestByKeyword(keyword: String)
    case searchAudiosByKeyword(keyword: String, page: Int)
}

extension AudioAPI: APITargetType {
    public var host: APIHost {
        return "http://tingapi.ting.baidu.com"
    }
    
    public var path: APIPath {
        return "v1/restserver/ting"
    }
    
    public var task: APITask {
        /// AudioURLEncoding - 专为百度音乐api接口而生
        return .requestParameters(parameters: parameters, encoding: AudioURLEncoding.default)
    }
    
    public var method: APIMethod {
        return .get
    }

    public var parameters: APIParameters {
        switch self {
        case let .fetchAudioList(type, offset):
            return ["format" : "json",
                    "from" : "qianqian",
                    "version" : "7.0.2",
                    "method" : "baidu.ting.billboard.billList&size=10&offset=\(offset)&type=\(type)"]
            
        case let .fetchAudioInfo(songId):
            return ["format" : "json",
                    "from" : "qianqian",
                    "version" : "7.0.2",
                    "method" : "baidu.ting.song.play&songid=\(songId ?? "")"]
            
        case let .searchSuggestByKeyword(keyword):
            return ["format" : "json",
                    "from" : "qianqian",
                    "version" : "7.0.2",
                    "method" : "baidu.ting.search.catalogSug&query=\(keyword)"]
            
        case let .searchAudiosByKeyword(keyword, page):
            return ["format" : "json",
                    "from" : "qianqian",
                    "version" : "7.0.2",
                    "method" : "baidu.ting.search.merge&query=\(keyword)&page_size=10&page_no=\(page)"]
        }
    }
}
