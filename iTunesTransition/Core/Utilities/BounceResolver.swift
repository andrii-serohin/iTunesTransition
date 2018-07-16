//
//  ScrollUpdater.swift
//  iTunesTransition
//
//  Created by Andrew Seregin on 23.06.2018.
//  Copyright © 2018 cookie. All rights reserved.
//

import UIKit

fileprivate class TransformUtility {
    
    var scrollUpdater: BounceResolver
    var isNeedNormalize: Bool = false
    
    private var deltaY: CGFloat?
    
    init(scrollUpdater: BounceResolver) {
        self.scrollUpdater = scrollUpdater
    }
    
    func normalizeY(translation: CGFloat) -> CGAffineTransform {
        
        var originalTransform = scrollUpdater.currentTransform.ty
        if let deltaY = deltaY {
            originalTransform -= deltaY
        }
        
        let translationY = isNeedNormalize ? originalTransform + translation : translation
        deltaY = translation
        return CGAffineTransform(translationX: 0,
                                 y: translationY)
        
    }
}

final class BounceResolver: NSObject {
    
    private(set) var isDismissEnabled = false
    
    private weak var rootView: UIView?
    private weak var scrollView: UIScrollView?
    private var transformNormalizer: TransformUtility?
    
    private var scrollOffset: CGFloat {
        guard let scrollView = scrollView else {
            return 0.0
        }
        let scrollOffset = scrollView.contentOffset.y + scrollView.contentInset.top
        guard #available(iOS 11, *) else { return scrollOffset }
        return scrollOffset + scrollView.safeAreaInsets.top
    }
    
    
    
    var currentTransform: CGAffineTransform {
        return rootView?.transform ?? .identity
    }

    init?(rootView: UIView) {
        guard let scrollView = rootView.detectedScrollView else { return nil }
        super.init()
        self.rootView = rootView
        self.scrollView = scrollView
        scrollView.delegate = self
        transformNormalizer = TransformUtility(scrollUpdater: self)
    }
    
    init(rootView: UIView, scrollView: UIScrollView) {
        super.init()
        self.rootView = rootView
        self.scrollView = scrollView
        scrollView.delegate = self
        transformNormalizer = TransformUtility(scrollUpdater: self)
    }
    
    func normalizeY(translation: CGFloat) -> CGAffineTransform? {
        return transformNormalizer?.normalizeY(translation: translation)
    }
    
    private func scrollViewDidScroll() {
        
        let isDecelerating = scrollView?.isDecelerating ?? false
        
        guard scrollOffset <= 0 else {
            scrollView?.bounces = true
            isDismissEnabled = false
            return
        }
        
        guard isDecelerating else {
            
            if scrollView!.isTracking {
                transformNormalizer?.isNeedNormalize = true
                scrollView?.subviews.forEach {
                    $0.transform = CGAffineTransform(translationX: 0, y: self.scrollOffset)
                }
            }
            
            scrollView?.bounces = false
            isDismissEnabled = true
            return
        }
        
        rootView?.transform = CGAffineTransform(translationX: 0, y: -scrollOffset)
        scrollView?.subviews.forEach {
            $0.transform = CGAffineTransform(translationX: 0, y: self.scrollOffset)
        }

    }
    
}

extension BounceResolver: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollViewDidScroll()
    }
    
}





