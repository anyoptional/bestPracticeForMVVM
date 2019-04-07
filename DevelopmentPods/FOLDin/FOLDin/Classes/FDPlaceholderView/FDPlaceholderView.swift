//
//  FDPlaceholderView.swift
//  FDPlaceholderView
//
//  Created by Archer on 2019/3/24.
//

import UIKit

@objc public protocol FDPlaceholderViewDataSource: class {
    /// 返回state状态下需要显示的View
    @objc optional func placeholderView(_ placeholderView: FDPlaceholderView,
                                        viewForState state: FDPlaceholderView.State) -> FDReusableView?
}

/// 只针对默认的失败状态
@objc public protocol FDPlaceholderViewDelegate: class {
    @objc optional func placeholderViewWillBeginRetry(_ placeholderView: FDPlaceholderView)
}

/// 用法同UITableView
public class FDPlaceholderView: UIView {
    
    /// 加载状态
    @objc public enum State: Int {
        /// 没有数据
        case empty
        /// 加载失败
        case failed
        /// 正在加载
        case loading
        /// 加载完成
        case completed
    }
    
    public weak var delegate: FDPlaceholderViewDelegate?
    public weak var dataSource: FDPlaceholderViewDataSource?
    
    /// 注册复用的view
    public func register(_ viewClass: FDReusableView.Type, with identifier: String, for state: State) {
        var map = _registeredMap[state]!
        map[identifier] = viewClass
        _registeredMap[state] = map
    }
    
    /// 从缓存中取出view
    public func retrieveView(with identifier: String, for state: State) -> UIView  {
        let map = _registeredMap[state]!
        let hit = map.first { (element) -> Bool in
            return element.key == identifier
        }
        guard hit != nil else {
            fatalError("identifer \'\(identifier)\' not registered before.")
        }
        var reusingViews = _reusingMap[state]!
        for view in reusingViews {
            if view.identifier == identifier {
                return view
            }
        }
        let view = hit!.value.init()
        view.identifier = identifier
        reusingViews.insert(view)
        _reusingMap[state] = reusingViews
        return view
    }
    
    /// 占位图的当前状态
    public var state: State {
        didSet {
            guard state != oldValue else { return }
            isHidden = false
            subviews.forEach { $0.removeFromSuperview() }
            layer.removeAnimation(forKey: "_kCAAniamtionKey")
            let reusableView = dataSource?.placeholderView?(self, viewForState: state)
            if let view = reusableView {
                addSubview(view)
            } else {
                switch state {
                case .empty:
                    let view = retrieveView(with: "_kFDEmptyViewKey", for: state)
                    addSubview(view)
                case .failed:
                    let view = retrieveView(with: "_kFDFailedViewKey", for: state) as! FDFailedView
                    view.retryButton.addTarget(self, action: #selector(retryButtonTapped), for: .touchUpInside)
                    addSubview(view)
                case .loading:
                    let view = retrieveView(with: "_kFDLoadingViewKey", for: state)
                    addSubview(view)
                case .completed: isHidden = true
                }
            }
            setNeedsLayout()
            if let animation = animation {
                layer.add(animation, forKey: "_kCAAniamtionKey")
            }
        }
    }
    
    @objc private func retryButtonTapped() {
        delegate?.placeholderViewWillBeginRetry?(self)
    }
    
    /// 视图切换时的动画
    public var animation: CAAnimation? = {
        let animation = CATransition()
        animation.type = .fade
        animation.duration = 0.125
        animation.repeatCount = 1.0
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = true
        animation.timingFunction = CAMediaTimingFunction(name: .easeIn)
        return animation
    }()
    
    /// 调整当前具体状态视图的位置和大小
    /// 当前状态视图默认是和其父视图一样大的
    /// top left bottom right的具体意义和SnapKit定义的一致
    public var contentInset: UIEdgeInsets {
        didSet {
            setNeedsLayout()
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        subviews.forEach {
            let x = self.contentInset.left
            let y = self.contentInset.top
            let width = self.bounds.width - x + self.contentInset.right
            let height = self.bounds.height - y + self.contentInset.bottom
            $0.frame = CGRect(x: x, y: y, width: width, height: height)
        }
    }
    
    private lazy var _reusingMap: [State : Set<FDReusableView>] = {
        var map = [State : Set<FDReusableView>]()
        map[.empty] = Set<FDReusableView>()
        map[.failed] = Set<FDReusableView>()
        map[.loading] = Set<FDReusableView>()
        map[.completed] = Set<FDReusableView>()
        return map
    }()
    private lazy var _registeredMap: [State : [String : FDReusableView.Type]] = {
        var map = [State : [String : FDReusableView.Type]]()
        map[.empty] = [String : FDReusableView.Type]()
        map[.failed] = [String : FDReusableView.Type]()
        map[.loading] = [String : FDReusableView.Type]()
        map[.completed] = [String : FDReusableView.Type]()
        return map
    }()
    
    public init() {
        state = .completed
        contentInset = .zero
        super.init(frame: .zero)
        backgroundColor = .white
        isHidden = true // default to .completed
        register(FDEmptyView.self, with: "_kFDEmptyViewKey", for: .empty)
        register(FDFailedView.self, with: "_kFDFailedViewKey", for: .failed)
        register(FDLoadingView.self, with: "_kFDLoadingViewKey", for: .loading)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

fileprivate class FDEmptyView: FDReusableView {
    
    lazy var titleLabel: UILabel = {
        let v = UILabel()
        v.text = "什么都没有~"
        v.textAlignment = .center
        v.font = UIFont.systemFont(ofSize: 13)
        v.textColor = UIColor(rgbValue: 0x999999)
        addSubview(v)
        return v
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        titleLabel.width = width - 40
        titleLabel.height = 14
        titleLabel.left = 20
        titleLabel.centerY = height / 2
    }
    
}

fileprivate class FDFailedView: FDReusableView {
    
    lazy var titleLabel: UILabel = {
        let v = UILabel()
        v.text = "出错啦~"
        v.textAlignment = .center
        v.font = UIFont.systemFont(ofSize: 13)
        v.textColor = UIColor(rgbValue: 0x999999)
        addSubview(v)
        return v
    }()
    
    lazy var retryButton: UIButton = {
        let v = UIButton()
        v.layer.cornerRadius = 10
        v.layer.borderWidth = 0.8
        v.layer.masksToBounds = true
        v.setTitle("戳我试试", for: .normal)
        v.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        v.layer.borderColor = UIColor(rgbValue: 0xB3B4B5).cgColor
        v.setTitleColor(UIColor(rgbValue: 0xB3B4B5), for: .normal)
        addSubview(v)
        return v
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        titleLabel.width = width - 40
        titleLabel.height = 14
        titleLabel.left = 20
        titleLabel.centerY = height / 2
        
        retryButton.width = 66
        retryButton.height = 20
        retryButton.top = titleLabel.bottom + 15
        retryButton.centerX = titleLabel.centerX
    }
    
}

fileprivate class FDLoadingView: FDReusableView {
    
    lazy var indicatorView: UIActivityIndicatorView = {
        let v = UIActivityIndicatorView(style: .gray)
        v.startAnimating()
        addSubview(v)
        return v
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        indicatorView.centerX = width / 2
        indicatorView.centerY = height / 2
    }
    
}


