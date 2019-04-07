//
//  AudioPopupMenuViewModel.swift
//  AppMusic
//
//  Created by Archer on 2019/2/25.
//

import Fate
import AudioService

protocol AudioPopupMenuViewModelInputs {
    func configure(value: MusicInfo)
}

protocol AudioPopupMenuViewModelOutputs {
    var audio: MusicInfo? { get }
    var titleAttributedText: NSAttributedString? { get }
}

protocol AudioPopupMenuViewModelType {
    var inputs: AudioPopupMenuViewModelInputs { get }
    var outputs: AudioPopupMenuViewModelOutputs { get }
}

class AudioPopupMenuViewModel: AudioPopupMenuViewModelType
    , AudioPopupMenuViewModelInputs
    , AudioPopupMenuViewModelOutputs {
    
    func configure(value: MusicInfo) {
        audio = value
        let title = value.musicName.filterNil()
        let titleAttrText = NSMutableAttributedString(string: title,
                                                     attributes: [.font : UIFont.systemFont(ofSize: 15),
                                                                  .foregroundColor : GLarkdef.gray_646580])
        titleAttributedText = titleAttrText.fd.copy()
    }
    
    var inputs: AudioPopupMenuViewModelInputs {
        return self
    }
    
    var outputs: AudioPopupMenuViewModelOutputs {
        return self
    }
    
    var audio: MusicInfo?
    var titleAttributedText: NSAttributedString?
}
