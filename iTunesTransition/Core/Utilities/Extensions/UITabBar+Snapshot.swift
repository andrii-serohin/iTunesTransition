//
//  UITabBar+Snapshot.swift
//  iTunesTransition
//
//  Created by Andrew Seregin on 13.07.2018.
//  Copyright © 2018 cookie. All rights reserved.
//

import UIKit

extension UITabBar {

    var snapshot: UIView? {
        
        let separator = subviews.first?.subviews.first(where: { $0 is UIImageView })?.snapshotView(afterScreenUpdates: false)
        let snapshot = snapshotView(afterScreenUpdates: true)
        
        if let separator = separator, let snapshot = snapshot {
            snapshot.addSubview(separator)
        }
        
        return snapshot
    }
    
}
