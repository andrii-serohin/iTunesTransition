//
//  PresentationController.swift
//  iTunesTransition
//
//  Created by Andrew Seregin on 21.06.2018.
//  Copyright © 2018 Andrew Seregin. All rights reserved.
//

import UIKit

class PresentationController: UIPresentationController {
    
    var isPresenting = false
    
    var tabBarSnapshot: UIView?
    private var snapshotConstraint: NSLayoutConstraint?
    
    private var presentedControllerHeightConstraint: NSLayoutConstraint?
    private var presentedControllerTopConstraint: NSLayoutConstraint?
    
    var duration: TimeInterval = 0.6
    
    private var scaleFactor: CGFloat {
        guard let container = containerView else { return 0 }
        let persent = Constants.statusBarHeight * 1.5 / container.bounds.height
        return 1 - persent
    }
    
    private var dimming: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.alpha = 0.0
        return view
    }()
    
    override func presentationTransitionWillBegin() {
        
        guard let containerView = containerView, let window = containerView.window else { return }
        
        guard let coordinator = presentedViewController.transitionCoordinator else { return }
        
        containerView.addSubview(dimming)
        dimming.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([dimming.leftAnchor.constraint(equalTo: window.leftAnchor),
                                     dimming.topAnchor.constraint(equalTo: window.topAnchor),
                                     dimming.rightAnchor.constraint(equalTo: window.rightAnchor),
                                     dimming.bottomAnchor.constraint(equalTo: window.bottomAnchor)])
        
        coordinator.animate(alongsideTransition: { (context) in
            self.dimming.alpha = 0.5
        })
        
    }
    
}

extension PresentationController {
    
    override func dismissalTransitionWillBegin() {
        
        guard let coordinator = presentedViewController.transitionCoordinator else { return }
        
        coordinator.animate(alongsideTransition: { context in
            self.dimming.alpha = 0.0
        }, completion: { context in
            guard context.isCancelled else {
                self.dimming.removeFromSuperview()
                return
            }
        })
    }
    
}

extension PresentationController: UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        guard let presented = presentedView else { return }
        guard let container = containerView else { return }
      
        guard let presentedController = presentedViewController as? FlexibleViewController else { return }
        guard let presentingController = presentingViewController as? PlayerTabBarViewController else { return }
        guard let contentView = presentingController.selectedViewController?.view else { return }
        
        guard isPresenting else {
            
            UIView.animate(withDuration: duration,
                           delay: 0,
                           usingSpringWithDamping: 0.8,
                           initialSpringVelocity: 0.5,
                           options: .curveEaseInOut,
                           animations: {
                            
                contentView.layer.cornerRadius = 0
                contentView.transform = .identity
                contentView.frame = self.frameOfPresentedViewInContainerView
                
                presentingController.player.isHidden = true
                self.snapshotConstraint?.constant = 0
                self.presentedControllerTopConstraint?.constant = presentingController.player.frame.origin.y - presentedController.view.transform.ty
                self.presentedControllerHeightConstraint?.constant = Constants.playerHeight
                presentedController.onShrink()
                container.layoutIfNeeded()
                
                presented.layer.cornerRadius = 0
                
                            
            }, completion: { isCompleted in
                if !transitionContext.transitionWasCancelled {
                    self.tabBarSnapshot?.removeFromSuperview()
                    self.tabBarSnapshot = nil
                    presentingController.player.isHidden = false
                }
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            })
            
            return
        }

        container.addSubview(presented)
        presented.translatesAutoresizingMaskIntoConstraints = false
        presented.leftAnchor.constraint(equalTo: container.leftAnchor).isActive = true
        presented.rightAnchor.constraint(equalTo: container.rightAnchor).isActive = true
        
        let deltaY = container.bounds.height - presentingController.tabBar.bounds.height - presentingController.player.bounds.height
        presentedControllerTopConstraint = presented.topAnchor.constraint(equalTo: container.topAnchor,
                                                                          constant: deltaY)
        presentedControllerHeightConstraint = presented.heightAnchor.constraint(equalToConstant: Constants.playerHeight)
        presentedControllerTopConstraint?.isActive = true
        presentedControllerHeightConstraint?.isActive = true
        
        tabBarSnapshot = presentingController.tabBar.snapshot
        tabBarSnapshot.flatMap {
            container.addSubview($0)
        }
        
        tabBarSnapshot?.translatesAutoresizingMaskIntoConstraints = false
    
        NSLayoutConstraint.activate([tabBarSnapshot?.leftAnchor.constraint(equalTo: container.leftAnchor),
                                     tabBarSnapshot?.rightAnchor.constraint(equalTo: container.rightAnchor),
                                     tabBarSnapshot?.heightAnchor.constraint(equalTo: presentingController.tabBar.heightAnchor)].compactMap{ $0 })
        snapshotConstraint = tabBarSnapshot?.bottomAnchor.constraint(equalTo: presentingController.tabBar.bottomAnchor)
        snapshotConstraint?.isActive = true
        container.layoutIfNeeded()
        
        UIView.animate(withDuration: duration,
                       delay: 0,
                       usingSpringWithDamping: 0.9,
                       initialSpringVelocity: 0.5,
                       options: .curveEaseInOut,
                       animations: {
                        
            contentView.layer.cornerRadius = 10
            contentView.clipsToBounds = true
            
            let translatY = 20 - container.bounds.height * 0.05 / 2
            
            contentView.transform = contentView.transform.scaledBy(x: self.scaleFactor,
                                                                   y: self.scaleFactor)
                                                         .translatedBy(x: 0,
                                                                       y: translatY)
                        
            self.snapshotConstraint?.constant = self.tabBarSnapshot!.bounds.height
                        
            presentedController.onExpand()
            self.presentedControllerHeightConstraint?.constant = container.bounds.height - Constants.musicDetailsTopPadding
            self.presentedControllerTopConstraint?.constant = Constants.musicDetailsTopPadding
            container.layoutIfNeeded()
            presented.layer.cornerRadius = 10
            presented.clipsToBounds = true
                        
        }, completion: { isCompleted in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
        
    }
}
