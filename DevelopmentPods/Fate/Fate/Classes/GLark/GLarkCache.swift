//
//  GLarkCache.swift
//  Fate
//
//  Created by Archer on 2019/2/25.
//

import YYKit

/// 取代UserDefaults
public class GLarkCache: YYCache {
    public static let shared = GLarkCache(name: "com.glark.basic.cache")
}
