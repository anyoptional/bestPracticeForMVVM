//
//  GLarkWebView.swift
//  Fate
//
//  Created by Archer on 2019/2/25.
//

import WebKit

public class GLarkWebView: WKWebView {
    private lazy var progressView: UIProgressView = {
        let v = UIProgressView();
        v.progressTintColor = GLarkdef.blue_1687FF
        addSubview(v);
        return v;
    }()
    
    public init() {
        let config = WKWebViewConfiguration()
        config.preferences = WKPreferences()
        config.preferences.javaScriptEnabled = true;
        config.preferences.javaScriptCanOpenWindowsAutomatically = true;
        config.userContentController = WKUserContentController()
        config.processPool = WKProcessPool()
        super.init(frame: .zero, configuration: config)
        allowsBackForwardNavigationGestures = true
        
        let progress = rx.observeWeakly(Double.self, #keyPath(GLarkWebView.estimatedProgress))
            .map { Float($0 ?? 0) }
            .share(replay: 1, scope: .forever)
        progress
            .bind(to: progressView.rx.progress)
            .disposed(by: disposeBag)
        progress
            .map { $0 >= 0.99 }
            .bind(to: progressView.rx.isHidden)
            .disposed(by: disposeBag)
        
        progressView.snp.makeConstraints { (make) in
            make.top.left.right.equalTo(0)
            make.height.equalTo(2)
        }
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NSLog("%@ is deallocating...", className())
    }
}


