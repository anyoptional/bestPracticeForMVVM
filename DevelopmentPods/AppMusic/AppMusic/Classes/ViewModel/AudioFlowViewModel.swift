//
//  AudioFlowViewModel.swift
//  AppMusic
//
//  Created by Archer on 2019/2/25.
//

import Fate
import AudioService

protocol AudioFlowViewModelInputs {
    func configureWith(value: MusicInfo?)
}

protocol AudioFlowViewModelOutputs {
    var nameText: String? { get }
    var artistText: String? { get }
    var audioCoverURL: URL? { get }
}

protocol AudioFlowViewModelType {
    var inputs: AudioFlowViewModelInputs { get }
    var outputs: AudioFlowViewModelOutputs { get }
}

class AudioFlowViewModel: AudioFlowViewModelType
    , AudioFlowViewModelInputs
    , AudioFlowViewModelOutputs {
    
    func configureWith(value: MusicInfo?) {
        nameText = (value?.musicName).filterNil("暂无歌曲")
        artistText = (value?.singerName).filterNil("暂无歌手")
        audioCoverURL = URL(string: (value?.picUrl).filterNil())
    }
    
    var inputs: AudioFlowViewModelInputs {
        return self
    }
    
    var outputs: AudioFlowViewModelOutputs {
        return self
    }
    
    var nameText: String?
    var artistText: String?
    var audioCoverURL: URL?
}
