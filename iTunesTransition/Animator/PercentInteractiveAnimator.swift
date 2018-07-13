//
//  PresentInteractiveAnimator.swift
//  iTunesTransition
//
//  Created by Andrew Seregin on 21.06.2018.
//  Copyright © 2018 Andrew Seregin. All rights reserved.
//

import Foundation
import UIKit

protocol PresentInteractiveDelegate : class {
    func percentAnimatorWantInteract(_ animator: PercentInteractiveAnimator)
}

class PercentInteractiveAnimator: UIPercentDrivenInteractiveTransition {
    
    private var view: UIView
    private var needComplete = false
    
    weak var delegate: PresentInteractiveDelegate?
    
    init(source view: UIView) {
        self.view = view
        super.init()
        prepareGestureRecognizer()
    }
    
    private func prepareGestureRecognizer() {
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(gesture:)))
        view.addGestureRecognizer(gesture)
    }
    
}

@objc extension PercentInteractiveAnimator {
    
    private func handlePanGesture(gesture: UIPanGestureRecognizer) {
        
        let transition = gesture.translation(in: view)
        let delta = UIScreen.main.bounds.height - Constants.playerHeight - Constants.statusBarHeight
        
        let progress = -transition.y / delta
        completionSpeed = 0.5
        
        switch gesture.state {
        case .began:
            delegate?.percentAnimatorWantInteract(self)
        case .changed:
            needComplete = progress > 0.05
            update(progress)
        case .cancelled:
            cancel()
        case .ended:
            
            guard needComplete else {
                completionSpeed = 0.2
                return cancel()
            }
            
            completionSpeed = 1
            finish()

            break
        default:
            break
        }
    }
    
}
