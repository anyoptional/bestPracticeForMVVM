//
//  KeywordsCache.swift
//  AppMusic
//
//  Created by Archer on 2019/2/25.
//

import Fate

/// 简易的关键词存储
struct KeywordsCache {
    
    static func store(_ keyword: String?) {
        guard let keyword = keyword else { return }
        if cache == nil {
            cache = getCachedKeywords()
        }
        // 效率稍微好点(相比先remove再insert)
        if let i = cache!.firstIndex(of: keyword) {
            let e = cache![i]
            for j in (0..<i).reversed() {
                cache![j + 1] = cache![j]
            }
            cache![0] = e
        } else {
            cache!.insert(keyword, at: 0)
        }
    }
    
    static func restore() -> [String] {
        if cache == nil {
            cache = getCachedKeywords()
        }
        return cache!
    }
    
    static func removeAll() {
        cache?.removeAll()
        GLarkCache.shared?.removeObject(forKey: "_kAudioKeywordsCacheKey")
    }
    
    static func synchronize() {
        // 当前runloop空闲时再写
        // 这个缓存属于一个优先级比较低的操作
        // 即使慢一点写进去也没什么关系
        guard let object = cache as NSArray? else {
            debugPrint("No data needs to cache.")
            return
        }
        FDTransaction.default.commit {
            GLarkCache.shared?.setObject(object, forKey: "_kAudioKeywordsCacheKey")
            cache = nil
        }
    }
    
    private static var cache: [String]? = nil
    private static func getCachedKeywords() -> [String] {
        let object = GLarkCache.shared?.object(forKey: "_kAudioKeywordsCacheKey")
        return (object as? [String]) ?? []
    }
}
