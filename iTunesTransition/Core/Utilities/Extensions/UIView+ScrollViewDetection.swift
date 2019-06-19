//
//  UIViewController+ScrollViewDetection.swift
//  iTunesTransition
//
//  Created by Andrew Seregin on 23.06.2018.
//  Copyright © 2018 cookie. All rights reserved.
//

import UIKit

extension UIView {
    
    var detectedScrollView: UIScrollView? {
        return subviews.first { $0 is UIScrollView } as? UIScrollView
    }
    
}


