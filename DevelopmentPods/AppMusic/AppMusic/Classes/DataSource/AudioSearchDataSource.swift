//
//  AudioSearchDataSource.swift
//  AppMusic
//
//  Created by Archer on 2019/2/25.
//

import Fate
import AudioService

class AudioSearchDataSource: ValueCellDataSource {
    
    func load(cachedKeywords: [String]) {
        clearValues()
        set(values: [cachedKeywords], cellClass: AudioSearchHistoryCell.self, inSection: 0)
    }
    
    func load(audioList: [MusicInfo]) {
        clearValues()
        set(values: audioList, cellClass: AudioSearchResultCell.self, inSection: 0)
    }
    
    func append(audioList: [MusicInfo]) -> [IndexPath] {
        var indexPaths = [IndexPath]()
        audioList.forEach {
            indexPaths += [appendRow(value: $0, cellClass: AudioSearchResultCell.self, toSection: 0)]
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
        tableView?.fd.register(cellClass: AudioSearchResultCell.self)
        tableView?.fd.register(cellClass: AudioSearchHistoryCell.self)
    }
    
    override func configureCell(tableCell cell: UITableViewCell, with value: Any, for indexPath: IndexPath) {
        switch (cell, value) {
        case let (cell as AudioSearchHistoryCell, value as [String]):
            cell.configureWith(value: value)
        case let (cell as AudioSearchResultCell, value as MusicInfo):
            cell.configureWith(value: value)
        default: break
        }
    }
    
}
