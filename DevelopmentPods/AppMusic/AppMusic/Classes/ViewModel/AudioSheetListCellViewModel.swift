//
//  AudioSheetListCellViewModel.swift
//  AppMusic
//
//  Created by Archer on 2019/2/25.
//

import Fate
import RxSwift
import AudioService

protocol AudioSheetListCellViewModelInputs {
    func configure(value: MusicInfo)
    func configure(index: Int)
}

protocol AudioSheetListCellViewModelOutputs {
    var indexText: String? { get }
    var nameText: String? { get }
    var artistText: String? { get }
    var isCollection: Bool { get }
    var isPlaying: Bool { get }
}

protocol AudioSheetListCellViewModelType {
    var inputs: AudioSheetListCellViewModelInputs { get }
    var outputs: AudioSheetListCellViewModelOutputs { get }
}

class AudioSheetListCellViewModel: AudioSheetListCellViewModelType
    , AudioSheetListCellViewModelInputs
    , AudioSheetListCellViewModelOutputs {
    
    func configure(value: MusicInfo) {
        nameText = value.musicName
        artistText = value.singerName
        isPlaying = value.fd.isPlaying
        isCollection = value.isCollection
    }
    
    func configure(index: Int) {
        indexText = "\(index)"
    }
    
    var inputs: AudioSheetListCellViewModelInputs {
        return self
    }
    
    var outputs: AudioSheetListCellViewModelOutputs {
        return self
    }
    
    var indexText: String?
    var nameText: String?
    var artistText: String?
    var isPlaying: Bool = false
    var isCollection: Bool = false
}
