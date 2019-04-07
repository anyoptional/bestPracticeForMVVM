//
//  GLarkBannerViewModel.swift
//  AppMusic
//
//  Created by Archer on 2019/2/25.
//

import Fate
import RxSwift
import AudioService

protocol GLarkBannerViewModelInputs {
    /// 配置返回的banner数据
    func configure(bannerList: [MusicSheetInfo])
    
    /// 选中了哪个轮播图
    func didSelectItem(at index: Int)
}

protocol GLarkBannerViewModelOutputs {
    /// 返回的banner数据
    var bannerList: [MusicSheetInfo] { get }
    
    /// 选中的轮播数据
    var itemSelected: Observable<MusicSheetInfo> { get }
}

protocol GLarkBannerViewModelType {
    var inputs: GLarkBannerViewModelInputs { get }
    var outputs: GLarkBannerViewModelOutputs { get }
}

class GLarkBannerViewModel: GLarkBannerViewModelType
    , GLarkBannerViewModelInputs
    , GLarkBannerViewModelOutputs {
    
    init() {
        itemSelected = itemSelectedRelay.asObservable()
    }
    
    func configure(bannerList: [MusicSheetInfo]) {
        self.bannerList = bannerList
    }
    
    fileprivate let itemSelectedRelay = PublishSubject<MusicSheetInfo>()
    func didSelectItem(at index: Int) {
        itemSelectedRelay.onNext(bannerList[index])
    }
    
    var inputs: GLarkBannerViewModelInputs {
        return self
    }
    
    var outputs: GLarkBannerViewModelOutputs {
        return self
    }
    
    let itemSelected: Observable<MusicSheetInfo>
    private(set) var bannerList = [MusicSheetInfo]()
}
