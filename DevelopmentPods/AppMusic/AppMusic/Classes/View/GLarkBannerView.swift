//
//  GLarkBannerView.swift
//  AppMusic
//
//  Created by Archer on 2019/2/25.
//

import Fate
import YYKit
import RxSwift
import RxCocoa
import SnapKit
import RxSwiftExt
import AudioService
import SDCycleScrollView

protocol GLarkBannerViewDelegate: class {
    /// 选中了哪个轮播图
    func bannerViewDidTapped(at audioSheet: MusicSheetInfo)
}

/// 轮播视图
class GLarkBannerView: UICollectionReusableView, ValueCell {
    
    weak var delegate: GLarkBannerViewDelegate?

    fileprivate let viewModel: GLarkBannerViewModelType = GLarkBannerViewModel()
    
    fileprivate lazy var loopView: SDCycleScrollView = {
        let v = SDCycleScrollView()
        v.delegate = self
        v.backgroundColor = .white
        v.autoScrollTimeInterval = 4
        v.pageControlBottomOffset = 15
        v.pageDotColor = GLarkdef.gray_515453
        addSubview(v)
        return v
    }()
    
    func configureWith(value: [MusicSheetInfo]) {
        viewModel.inputs.configure(bannerList: value)
        loopView.numberOfItems = value.count
        loopView.reloadData()
    }
    
    private func performBinding() {
        viewModel.outputs.itemSelected
            .subscribeNext(weak: self) { (self) in
                return { (bannerResp) in
                    self.delegate?.bannerViewDidTapped(at: bannerResp)
                }
            }.disposed(by: disposeBag)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        buildUI()
        performBinding()
    }
    
    private func buildUI() {
        loopView.snp.makeConstraints { (make) in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(200)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension GLarkBannerView: SDCycleScrollViewDelegate {
    func cycleScrollView(_ cycleScrollView: SDCycleScrollView!, didSelectItemAt index: Int) {
        viewModel.inputs.didSelectItem(at: index)
    }
    
    func customCollectionViewCellClass(for view: SDCycleScrollView!) -> AnyClass! {
        return GLarkBannerCell.self
    }
    
    func setupCustomCell(_ cell: UICollectionViewCell!, for index: Int, cycleScrollView view: SDCycleScrollView!) {
        let cell = cell as? GLarkBannerCell
        let value = viewModel.outputs.bannerList[index].imgUrl
        cell?.configureWith(value: value)
    }
}
