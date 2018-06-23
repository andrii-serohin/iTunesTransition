//
//  ScrollUpdater.swift
//  iTunesTransition
//
//  Created by Andrew Seregin on 23.06.2018.
//  Copyright © 2018 cookie. All rights reserved.
//

import UIKit

final class ScrollUpdater {
    
    var isDismissEnabled = false
    
    private weak var rootView: UIView?
    private weak var scrollView: UIScrollView?
    private var observer: NSKeyValueObservation?

    private var scrollOffset: CGFloat {
        guard let scrollView = scrollView else { return 0.0 }
        let scrollOffset = scrollView.contentOffset.y + scrollView.contentInset.top
        guard #available(iOS 11, *) else { return scrollOffset }
        return scrollOffset + scrollView.safeAreaInsets.top
    }
    
    var isDecelerating: Bool {
        return scrollView?.isDecelerating ?? false
    }
    
    init(rootView: UIView, scrollView: UIScrollView) {
        self.rootView = rootView
        self.scrollView = scrollView
        self.observer = scrollView.observe(\.contentOffset, options: [.initial]) { [weak self] (_, _) in
            self?.scrollViewDidScroll()
        }
        
    }
    
    private func scrollViewDidScroll() {
        
        guard scrollOffset <= 0 else {
            scrollView?.bounces = true
            isDismissEnabled = false
            return
        }
        
        guard isDecelerating else {
            scrollView?.bounces = false
            isDismissEnabled = true
            return
        }
        
        rootView?.transform = CGAffineTransform(translationX: 0, y: -scrollOffset)
        scrollView?.subviews.forEach{
            $0.transform = CGAffineTransform(translationX: 0, y: self.scrollOffset)
        }

    }
    
    deinit {
        self.observer = nil
    }
}
