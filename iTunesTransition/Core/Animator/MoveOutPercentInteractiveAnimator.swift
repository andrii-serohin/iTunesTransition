//
//  MoveOutPercentInteractiveAnimator.swift
//  iTunesTransition
//
//  Created by Andrew Seregin on 21.06.2018.
//  Copyright © 2018 Andrew Seregin. All rights reserved.
//

import Foundation
import UIKit

protocol MoveOutPercentInteractiveAnimatorDelegate : class {
    func moveOutPercentAnimatorWillInteract(_ animator: MoveOutPercentInteractiveAnimator)
}

class MoveOutPercentInteractiveAnimator: UIPercentDrivenInteractiveTransition {
    
    private var view: UIView
    private var isNeedComplete = false
    
    private(set) var panGesture: UIPanGestureRecognizer?
    
    weak var delegate: MoveOutPercentInteractiveAnimatorDelegate?
    
    init(source view: UIView) {
        self.view = view
        super.init()
        prepareGestureRecognizer()
    }
    

    
}

private extension MoveOutPercentInteractiveAnimator {
    
    func prepareGestureRecognizer() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(gesture:)))
        view.addGestureRecognizer(panGesture)
        self.panGesture = panGesture
    }
    
}

@objc extension MoveOutPercentInteractiveAnimator {
    
    private func handlePanGesture(gesture: UIPanGestureRecognizer) {
        
        let transition = gesture.translation(in: view)
        let delta = UIScreen.main.bounds.height - Constants.playerHeight - UIApplication.shared.statusBarFrame.height
        
        let progress = -transition.y / delta
        completionSpeed = Constants.Animation.Speed.regular
        
        switch gesture.state {
        case .began:
            delegate?.moveOutPercentAnimatorWillInteract(self)
        case .changed:
            isNeedComplete = progress > Constants.Animation.Progress.completeValue
            update(progress)
        case .cancelled:
            cancel()
        case .ended:
            
            guard isNeedComplete else {
                
                completionSpeed = Constants.Animation.Speed.onCancel
                return cancel()
            }

            completionSpeed = Constants.Animation.Speed.onFinish
            finish()

            break
        default:
            break
        }
    }
    
}
