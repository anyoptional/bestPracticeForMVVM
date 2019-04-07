//
//  AudioSheetToolBarViewModel.swift
//  AppMusic
//
//  Created by Archer on 2019/2/25.
//

import Fate
import AudioService

protocol AudioSheetToolBarViewModelInputs {
    func configureWith(value: MusicInfo?)
}

protocol AudioSheetToolBarViewModelOutputs {
    var nameText: String? { get }
    var artistText: String? { get }
    var audioCoverURL: URL? { get }
}

protocol AudioSheetToolBarViewModelType {
    var inputs: AudioSheetToolBarViewModelInputs { get }
    var outputs: AudioSheetToolBarViewModelOutputs { get }
}

class AudioSheetToolBarViewModel: AudioSheetToolBarViewModelType
    , AudioSheetToolBarViewModelInputs
    , AudioSheetToolBarViewModelOutputs {

    func configureWith(value: MusicInfo?) {
        nameText = (value?.musicName).filterNil("暂无歌曲")
        artistText = (value?.singerName).filterNil("暂无歌手")
        audioCoverURL = URL(string: (value?.picUrl).filterNil())
    }
    
    var inputs: AudioSheetToolBarViewModelInputs {
        return self
    }
    
    var outputs: AudioSheetToolBarViewModelOutputs {
        return self
    }
    
    var nameText: String?
    var artistText: String?
    var audioCoverURL: URL?
}
