//
//  AudioSheetDataSource.swift
//  AppMusic
//
//  Created by Archer on 2019/2/25.
//

import Fate
import SkeletonView
import AudioService

class AudioSheetListDataSource: ValueCellDataSource, SkeletonTableViewDataSource {
    
    func load(audioList: [MusicInfo]) {
        clearValues()
        set(values: audioList, cellClass: AudioSheetListCell.self, inSection: 0)
    }
    
    
    func append(audioList: [MusicInfo]) -> [IndexPath] {
        var indexPaths = [IndexPath]()
        audioList.forEach {
            indexPaths += [appendRow(value: $0, cellClass: AudioSheetListCell.self, toSection: 0)]
        }
        return indexPaths
    }
    
    func load(flag: Bool, at indexPath: IndexPath) {
        guard let audio = self[indexPath] as? MusicInfo else { return }
        // 成功就更新
        if flag {
            audio.isCollection = !audio.isCollection
        }
    }
    
    override func registerClasses(tableView: UITableView?) {
        tableView?.fd.register(cellClass: AudioSheetListCell.self)
    }
    
    override func configureCell(tableCell cell: UITableViewCell, with value: Any, for indexPath: IndexPath) {
        switch (cell, value) {
        case let (cell as AudioSheetListCell, value as MusicInfo):
            cell.configureWith(index: indexPath.row + 1)
            cell.configureWith(value: value)
        default: break
        }
    }
    
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return AudioSheetListCell.defaultReusableId
    }
}
