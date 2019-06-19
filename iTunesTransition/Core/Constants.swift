//
//  Constants.swift
//  iTunesTransition
//
//  Created by Andrew Seregin on 21.06.2018.
//  Copyright © 2018 Andrew Seregin. All rights reserved.
//

import UIKit

enum Constants {
    
    enum Animation {
        static let duration: TimeInterval = 0.6
        
        enum Speed {
            static let regular: CGFloat = 0.5
            static let onCancel: CGFloat = 0.2
            static let onFinish: CGFloat = 1
        }
        
        enum Progress {
            static let completeValue: CGFloat =  0.05
        }
        
    }
    
    static let musicDetailsTopPadding: CGFloat = 50
    static let playerHeight: CGFloat = 120
    static let scaleFactor: CGFloat = 0.95
}
