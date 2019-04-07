//
//  AudioBoxDataSource.swift
//  AppMusic
//
//  Created by Archer on 2019/2/25.
//

import Fate
import AudioService

final class AudioBoxDataSource: ValueCellDataSource {

    func load(audioSheetList: [MusicSheetInfo]) {
        set(values: audioSheetList, cellClass: AudioRecommendCell.self, inSection: 0)
    }
    
    override func registerClasses(collectionView: UICollectionView?) {
        collectionView?.fd.register(AudioRecommendCell.self)
        collectionView?.fd.register(GLarkAudioHeaderView.self,
                        forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader)
    }
    
    
    override func configureCell(collectionCell cell: UICollectionViewCell, with value: Any, for indexPath: IndexPath) {
        switch (cell, value) {
        case let (cell as AudioRecommendCell, value as MusicSheetInfo):
            cell.configureWith(value: value)
        default: break
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        let view: GLarkAudioHeaderView = collectionView.fd.dequeueReusableSupplementaryView(ofKind: kind, for: indexPath)
        return view
    }
}
