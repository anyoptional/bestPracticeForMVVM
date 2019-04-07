//
//  FDProgressBar.swift
//  AppMusic
//
//  Created by Archer on 2019/2/25.
//

import UIKit

public protocol FDProgressBarDelegate: class {
    /// 值改变时回调
    func progressBar(_ progressBar: FDProgressBar, valueChanged newValue: Double)
}

public class FDProgressBar: UIView {
    
    public weak var delegate: FDProgressBarDelegate?
    
    /// 滑块的进度值
    public var value: Double {
        set {
            slider.value = Float(newValue)
            layoutIndicatorView()
        }
        get {
            return Double(slider.value)
        }
    }
    
    /// 滑块缓冲的进度值
    public var bufferValue: Double {
        set {
            let total = maximumValue - minimumValue
            slider.progressView.progress = Float(newValue / total)
        }
        get {
            let total = maximumValue - minimumValue
            return Double(slider.progressView.progress) * total
        }
    }
    
    /// 滑块的最大值
    public var maximumValue: Double {
        set {
            slider.maximumValue = Float(newValue)
        }
        get {
            return Double(slider.maximumValue)
        }
    }
    
    /// 滑块的最小值
    public var minimumValue: Double {
        set {
            slider.minimumValue = Float(newValue)
        }
        get {
            return Double(slider.minimumValue)
        }
    }
    
    /// 总进度条颜色
    public var maximumTrackTintColor: UIColor? {
        set {
            slider.progressView.progressTintColor = newValue
        }
        get {
            return slider.progressView.progressTintColor
        }
    }
    
    /// 当前进度颜色
    public var minimumTrackTintColor: UIColor? {
        set {
            slider.minimumTrackTintColor = newValue
        }
        get {
            return slider.minimumTrackTintColor
        }
    }
    
    /// 缓冲进度颜色
    public var bufferTrackTintColor: UIColor? {
        set {
            slider.progressView.trackTintColor = newValue
        }
        get {
            return slider.progressView.trackTintColor
        }
    }
    
    /// 总进度条图片
    public var maximumTrackImage: UIImage? {
        set {
            slider.progressView.progressImage = newValue
        }
        get {
            return slider.progressView.progressImage
        }
    }
    
    /// 当前进度图片
    public var minimumTrackImage: UIImage? {
        set {
            slider.setMinimumTrackImage(newValue, for: .normal)
        }
        get {
            return slider.minimumTrackImage(for: .normal)
        }
    }
    
    /// 缓冲进度图片
    public var bufferTrackImage: UIImage? {
        set {
            slider.progressView.trackImage = newValue
        }
        get {
            return slider.progressView.trackImage
        }
    }
    
    /// 圆环的颜色
    public var thumbTintColor: UIColor? {
        set {
            slider.thumbTintColor = newValue
        }
        get {
            return slider.thumbTintColor
        }
    }
    
    /// 圆环的图片
    public var thumbImage: UIImage? {
        set {
            slider.setThumbImage(newValue, for: .normal)
        }
        get {
            return slider.thumbImage(for: .normal)
        }
    }
    
    /// 是否允许点击触发
    public var isAllowsTap: Bool {
        didSet {
            tapGesture.isEnabled = isAllowsTap
        }
    }
    
    /// 是否正在拖动
    public private(set) var isDragging: Bool
    
    /// 滑动时是否连续触发
    public var isContinuous: Bool {
        set {
            slider.isContinuous = newValue
        }
        get {
            return slider.isContinuous
        }
    }
    
    /// 滑块额外点击区域
    public var touchAreaInsets: UIEdgeInsets
    
    /// 菊花的样式
    public var indicatorStyle: UIActivityIndicatorView.Style {
        set {
            indicatorView.style = newValue
        }
        get {
            return indicatorView.style
        }
    }
    
    /// 是否正在缓冲
    public var isBuffering: Bool {
        didSet {
            if isBuffering {
                startBuffering()
            } else {
                stopBuffering()
            }
        }
    }
    
    /// 显示菊花
    private func startBuffering() {
        indicatorView.isHidden = false
        indicatorView.startAnimating()
    }
    
    /// 隐藏菊花
    private func stopBuffering() {
        indicatorView.isHidden = true
        indicatorView.stopAnimating()
    }
    
    @objc private func tapReceived(_ sender: UITapGestureRecognizer) {
        stopBuffering()
        isDragging = true
        let touchPoint = sender.location(in: slider)
        let value = (slider.maximumValue - slider.minimumValue) * Float(touchPoint.x / frame.size.width)
        slider.setValue(value, animated: true)
        if isBuffering {
            startBuffering()
        }
        layoutIndicatorView()
        delegate?.progressBar(self, valueChanged: Double(value))
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(Int(0.3 * 1000))) {
            self.isDragging = false // seek操作需要时间，这期间不能更新value，延时解决
        }
    }
    
    @objc private func touchesBegan(_ sender: UISlider) {
        stopBuffering()
        isDragging = true
        tapGesture.isEnabled = false
    }
    
    @objc private func touchesEnded(_ sender: UISlider) {
        if isBuffering {
            startBuffering()
        }
        layoutIndicatorView()
        delegate?.progressBar(self, valueChanged: Double(sender.value))
        tapGesture.isEnabled = isAllowsTap
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(Int(0.3 * 1000))) {
            self.isDragging = false // seek操作需要时间，这期间不能更新value，延时解决
        }
    }
    
    @objc private func valueChanged(_ sender: UISlider) {
        if isContinuous {
            delegate?.progressBar(self, valueChanged: Double(sender.value))
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        slider.frame = bounds
        layoutIndicatorView()
    }
    
    private func layoutIndicatorView() {
        indicatorView.sizeToFit()
        let thumbFrame = slider.thumbRect(forBounds: bounds, trackRect: slider.trackRect(forBounds: bounds), value: slider.value)
        indicatorView.center = CGPoint(x: thumbFrame.origin.x + thumbFrame.size.width / 2, y: thumbFrame.origin.y + thumbFrame.height / 2)
        let scale = 0.6 * thumbFrame.width / indicatorView.frame.width
        indicatorView.transform = CGAffineTransform(scaleX: scale, y: scale)
    }
    
    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if indicatorView.frame.contains(point) {
            return slider
        }
        return super.hitTest(point, with: event)
    }
    
    private var slider = FDSlider()
    private var tapGesture = UITapGestureRecognizer()
    private var indicatorView = UIActivityIndicatorView(style: .gray)
    
    public convenience init() {
        self.init(frame: .zero)
    }
    
    public override init(frame: CGRect) {
        isDragging = false
        isAllowsTap = true
        isBuffering = false
        touchAreaInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        super.init(frame: frame)
        addSubview(slider)
        addSubview(indicatorView)
        indicatorView.hidesWhenStopped = true
        slider.addGestureRecognizer(tapGesture)
        slider.touchAreaInsets = touchAreaInsets
        tapGesture.addTarget(self, action: #selector(tapReceived(_:)))
        slider.addTarget(self, action: #selector(touchesBegan(_:)), for: .touchDown)
        slider.addTarget(self, action: #selector(touchesEnded(_:)), for: .touchUpInside)
        slider.addTarget(self, action: #selector(touchesEnded(_:)), for: .touchUpOutside)
        slider.addTarget(self, action: #selector(valueChanged(_:)), for: .valueChanged)
    }
    
    deinit {
        slider.removeGestureRecognizer(tapGesture)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

fileprivate class FDSlider: UISlider {
    
    var touchAreaInsets: UIEdgeInsets
    
    override func layoutSubviews() {
        super.layoutSubviews()
        progressView.frame.size.height = bounds.size.height
        progressView.frame.size.width = bounds.size.width - 3.5
        progressView.center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let thumbFrame = thumbRect(forBounds: bounds, trackRect: trackRect(forBounds: bounds), value: value)
        let result = super.hitTest(point, with: event)
        if result !== self {
            if point.y >= -touchAreaInsets.top &&
                point.y < (thumbFrame.height + touchAreaInsets.bottom) &&
                point.x >= -touchAreaInsets.left &&
                point.x < bounds.width + touchAreaInsets.right {
                return self
            }
        }
        return result
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let thumbFrame = thumbRect(forBounds: bounds, trackRect: trackRect(forBounds: bounds), value: value)
        let result = super.point(inside: point, with: event)
        if !result {
            if point.x >= (thumbFrame.minX - touchAreaInsets.left) &&
                point.x <= (thumbFrame.minX + thumbFrame.width + touchAreaInsets.right) &&
                point.y >= -touchAreaInsets.top &&
                point.y < (thumbFrame.height + touchAreaInsets.bottom) {
                return true
            }
        }
        return result
    }
    
    lazy var progressView: UIProgressView = {
        let v = UIProgressView()
        insertSubview(v, at: 0)
        return v
    }()
    
    init() {
        touchAreaInsets = .zero
        super.init(frame: .zero)
        maximumTrackTintColor = .clear
        setMaximumTrackImage(nil, for: .normal)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
