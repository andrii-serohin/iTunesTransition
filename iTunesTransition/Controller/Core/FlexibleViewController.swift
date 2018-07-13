//
//  FlexibleViewController.swift
//  iTunesTransition
//
//  Created by Andrew Seregin on 13.07.2018.
//  Copyright © 2018 cookie. All rights reserved.
//

import UIKit

protocol FlexibleViewControllerDelegate: class {
    var dismissThreshold: CGFloat { get }
    func flexibleViewController(_ viewController: FlexibleViewController, updateProgress current: CGFloat)
}

class FlexibleViewController: UIViewController {
    
    private var bouncesResolver: BounceResolver?
    private var panRecognizer: UIPanGestureRecognizer?
    
    weak var delegate: FlexibleViewControllerDelegate?
    
    //TODO: Change name to more descriptive
    var isAllowDismisSwipe: Bool {
        return bouncesResolver?.isDismissEnabled ?? true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareGestureRecognizers()
    }
    
    private func prepareGestureRecognizers() {
        let panRecognizer = UIPanGestureRecognizer(target: self,
                                                   action: #selector(handlePan(gesture:)))
        view.addGestureRecognizer(panRecognizer)
        self.panRecognizer = panRecognizer
        self.panRecognizer?.delegate = self
        
    }
    
    private func deformFlexibleController(according translation: CGFloat, currentProgress: CGFloat) {
        
        let threshold = delegate?.dismissThreshold ?? 350
        
        guard translation >= 0 else { return }
        delegate?.flexibleViewController(self, updateProgress: currentProgress)
        view.transform = bouncesResolver?.normalizeY(translation: elasticTranslation(from: translation)) ?? .identity
        
        if translation >= threshold {
            dismiss(animated: true)
        }
    }
    
    private func elasticTranslation(from currentTranslation: CGFloat) -> CGFloat {
        
        let factor: CGFloat = 1/2
        let threshold: CGFloat = 120
        
        guard currentTranslation >= threshold else {
            return currentTranslation * factor
        }
        
        let length = currentTranslation - threshold
        let friction = 30 * atan(length / 120) + length / 3
        return friction + threshold * factor
    }
    
    public func onShrink() {}
    public func onExpand() {}
    
    
}

@objc extension FlexibleViewController {
    
    private func handlePan(gesture: UIPanGestureRecognizer) {
        
        guard gesture.isEqual(panRecognizer), isAllowDismisSwipe else { return }
        
        guard !isBeingDismissed else {
            gesture.isEnabled = false
            return
        }
        
        let translation = gesture.translation(in: view)
        
        //TODO: Need to change playerHeight to dynamically calculated property
        let progress = translation.y / (view.frame.height - Constants.playerHeight)
        
        switch gesture.state {
        case .began:
            
            guard bouncesResolver == nil else { return }
            bouncesResolver = BounceResolver(rootView: view)
            
        case .changed:
            
            guard isAllowDismisSwipe else { return }
            deformFlexibleController(according: translation.y, currentProgress: progress)
            
        case .ended:
            
            guard isAllowDismisSwipe else { return }
            
            guard progress > 0.2 else {
                
                UIView.animate(withDuration: 0.2 + Double(progress) * 0.2,
                               delay: 0,
                               options: .curveEaseInOut,
                               animations: {
                                
                                self.delegate?.flexibleViewController(self, updateProgress: 0)
                                self.view.transform = .identity
                })
                
                return
            }
            
            dismiss(animated: true)
            
            
        default:
            break
        }
    }
    
}

extension FlexibleViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return gestureRecognizer.isEqual(panRecognizer)
    }
    
}
