//
//  AudioObjects.swift
//  AudioService
//
//  Created by Archer on 2019/4/5.
//

import Foundation

@objcMembers
public class MusicSheetInfo: NSObject {
    public var title: String?
    public var imgUrl: String?
    public var type: Int = 1
}

@objcMembers
public class MusicInfo: AudioItem {
    
    public var musicId: String?
    public var picUrl: String?
    public var lrcUrl: String?
    public var musicName: String?
    public var singerName: String?
    public var isCollection = false
    
    public override func isEqual(_ object: Any?) -> Bool {
        guard let another = object as? MusicInfo else { return false }
        guard let id = musicId, let anotherId = another.musicId else { return false }
        return id == anotherId
    }
    
    public override var hash: Int {
        guard let id = musicId else {
            return super.hash
        }
        return id.hash
    }
}
