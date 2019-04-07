//
//  AudioSearchResultCellViewModel.swift
//  AppMusic
//
//  Created by Archer on 2019/2/25.
//

import Fate
import AudioService

protocol AudioSearchResultCellViewModelInputs {
    func configure(value: MusicInfo)
}

protocol AudioSearchResultCellViewModelOutputs {
    var nameAttributedText: NSAttributedString? { get }
    var artistAttributedText: NSAttributedString? { get }
    var isCollection: Bool { get }
}

protocol AudioSearchResultCellViewModelType {
    var inputs: AudioSearchResultCellViewModelInputs { get }
    var outputs: AudioSearchResultCellViewModelOutputs { get }
}

class AudioSearchResultCellViewModel: AudioSearchResultCellViewModelType
    , AudioSearchResultCellViewModelInputs
    , AudioSearchResultCellViewModelOutputs {
    
    func configure(value: MusicInfo) {
        let highlightedKey = value.fd.highlightedKey.filterNil()
        
        let name = value.musicName.filterNil()
        let nameAttrText = NSMutableAttributedString(string: name,
                                                     attributes: [.font : UIFont.systemFont(ofSize: 16),
                                                                  .foregroundColor : GLarkdef.black_333345])
        nameAttrText.addAttributes([.foregroundColor : GLarkdef.blue_1687FF],
                                   range: (name.lowercased() as NSString).range(of: highlightedKey.lowercased()))
        nameAttributedText = nameAttrText.fd.copy()
        
        let artist = value.singerName.filterNil()
        let artistAttrText = NSMutableAttributedString(string: artist,
                                                       attributes: [.font : UIFont.systemFont(ofSize: 12),
                                                                    .foregroundColor : GLarkdef.gray_646580])
        artistAttrText.addAttributes([.foregroundColor : GLarkdef.blue_1687FF],
                                     range: (artist.lowercased() as NSString).range(of: highlightedKey.lowercased()))
        artistAttributedText = artistAttrText.fd.copy()
        
        isCollection = value.isCollection
    }
    
    var inputs: AudioSearchResultCellViewModelInputs {
        return self
    }
    
    var outputs: AudioSearchResultCellViewModelOutputs {
        return self
    }
    
    var isCollection: Bool = false
    var nameAttributedText: NSAttributedString?
    var artistAttributedText: NSAttributedString?
}
